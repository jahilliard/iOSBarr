//
//  LocationTracker.swift
//  barr
//
//  Created by Justin Hilliard on 3/14/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

let LATITUDE = "latitude"
let LONGITUDE = "longitude"
let ACCURACY = "theAccuracy"

protocol CoordinateDelegate {
    // protocol definition goes here
    func updateCoordinates();
}

let mapViewLocationNotificationKey = "com.barrapp.locationUpdated";
let updatedNearbyLocationsNotification = "com.barapp.updatedNearbyLocationNotification";
let updatedCoordinateNotificationKey = "com.barapp.updatedCoordinateNotification";

class LocationTracker : NSObject {
    static var sharedInstance: LocationTracker = LocationTracker();
    var needRefresh : Bool = false;
    var locationDelegate: CLLocationManagerDelegate!;
    var coordinateDelegate : CoordinateDelegate!;
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var currentCoord: CLLocationCoordinate2D?
    var nearbyLocations: [Location] = [];
    let LOCATION_SEARCH_RADIUS : Double = 200;
    let TRACKING_RADIUS : Double = 200;
    let SEARCH_REGION_IDENTIFIER = "SEARCH_REGION";
    var lastRefreshTime : NSDate! = nil;
    let MIN_REFRESH_INTERVAL : Double = 120;
    var isBackgrounded : Bool = false;
    var initialized : Bool = false;
    
    private override init()  {
        super.init();
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.appWillEnterBackground(_:)), name: appWillEnterBackgroundNotification, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.appWillEnterForeground(_:)), name: appWillEnterForegroundNotification, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.handleUpdatedCoordinate(_:)), name: updatedCoordinateNotificationKey, object: nil);
    }
    
    func reset(){
        self.currentLocation = nil;
        self.currentCoord = nil;
        self.nearbyLocations = [];
    }
    
    func appWillEnterBackground(notification: NSNotification){
        if let foregroundManager = self.locationManager.delegate as? ForegroundLocationManagerDelegate {
            foregroundManager.close();
        }
        
        let locationDelegate = BackgroundLocationManagerDelegate();
        self.locationDelegate = locationDelegate;
        self.locationManager.delegate = self.locationDelegate;
        self.coordinateDelegate = locationDelegate;
        self.isBackgrounded = true;
    }
    
    func appWillEnterForeground(notification: NSNotification){
        if let backgroundManager = self.locationManager.delegate as? BackgroundLocationManagerDelegate {
            backgroundManager.close();
        }
        
        let locationDelegate = ForegroundLocationManagerDelegate();
        self.locationDelegate = locationDelegate;
        self.coordinateDelegate = locationDelegate;
        self.locationManager.delegate = self.locationDelegate;
        self.isBackgrounded = false;
    }
    
    func getUpdatedCoordinates() {
        self.coordinateDelegate.updateCoordinates();
    }
    
    func startLocationTracking() {
        self.initialized = true;
        self.needRefresh = true;
        //initialize locationManager
        let locationDelegate = ForegroundLocationManagerDelegate();
        self.locationDelegate = locationDelegate;
        self.coordinateDelegate = locationDelegate;
        self.locationManager.delegate = self.locationDelegate;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.allowsBackgroundLocationUpdates = true;
        if CLLocationManager.locationServicesEnabled() == false {
            ErrorHandler.showEventsAcessDeniedAlert("Change Permissions", message: "Please change your location permissions to Always")
        } else {
            CLLocationManager.authorizationStatus();
        }
    }
    
    func registerRegionsToMonitor(nearbyLocations: [Location]){
        for loc in nearbyLocations {
            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: CLLocationDegrees(loc.lat), longitude: CLLocationDegrees(loc.lon)), radius: max(self.TRACKING_RADIUS, loc.radius), identifier: loc.id);
            region.notifyOnEntry = true;
            region.notifyOnExit = true;
            print("monitoring region \(region)")
            self.locationManager.startMonitoringForRegion(region);
        }
    }
    
    func stopMonitoringRegions(){
        for region in self.locationManager.monitoredRegions {
            self.locationManager.stopMonitoringForRegion(region);
        }
    }
    
    func handleUpdatedCoordinate(notification: NSNotification) {
        if let info = notification.userInfo as? Dictionary<String, AnyObject>, newestLocation = info["newLocation"] as? CLLocation, lat = newestLocation.coordinate.latitude as Double?, long = newestLocation.coordinate.longitude as Double?
        {
            self.currentLocation = newestLocation;
            self.currentCoord = CLLocationCoordinate2DMake(lat, long);
            
            //update current coordinates on map
            if UIApplication.sharedApplication().applicationState != .Background {
                NSNotificationCenter.defaultCenter().postNotificationName(mapViewLocationNotificationKey, object: self);
            }
            
            if self.needRefresh {
                //TODO: set to false after successful get
                self.needRefresh = false;
                self.getCircleLocationInfo(newestLocation);
            }
        }
    }
    
    func getFreshLocationInfo() {
        let currentTime = NSDate();
        /*if let lastRefreshTime = self.lastRefreshTime {
            print(currentTime.timeIntervalSinceDate(lastRefreshTime));
            if currentTime.timeIntervalSinceDate(lastRefreshTime) < MIN_REFRESH_INTERVAL {
                return;
            }
        }*/
    
        self.reset();
        self.needRefresh = true;
        if self.initialized {
            self.getUpdatedCoordinates();
        }
        self.lastRefreshTime = currentTime;
    }
    
    func getCircleLocationInfo(newestLocation: CLLocation){
        if let lat = newestLocation.coordinate.latitude as Double?, long = newestLocation.coordinate.longitude as Double?
        {
            Location.getLocations(lat, lon: long, radius: LOCATION_SEARCH_RADIUS, completion: {
                nearByLocations in
                self.stopMonitoringRegions();
                self.registerRegionsToMonitor(nearByLocations);
                
                //add new search radius region
                let region = CLCircularRegion(center: newestLocation.coordinate, radius: self.LOCATION_SEARCH_RADIUS, identifier: self.SEARCH_REGION_IDENTIFIER);
                region.notifyOnEntry = true;
                region.notifyOnExit = true;
                self.locationManager.startMonitoringForRegion(region);
                
                //update nearby locations on map
                if UIApplication.sharedApplication().applicationState != .Background {
                    NSNotificationCenter.defaultCenter().postNotificationName(mapViewLocationNotificationKey, object: self);
                }
                
                //tell listeners there are new locations
                NSNotificationCenter.defaultCenter().postNotificationName(updatedNearbyLocationsNotification, object: self);
            });
        }
    }
    
    
    func getContainingRegions(coord : CLLocation) -> ([Location], [Location]){
        var inLocations = [Location]();
        var trackingLocations = [Location]();
        for loc in self.nearbyLocations {
            let distance = coord.distanceFromLocation(CLLocation(latitude: loc.lat, longitude: loc.lon))
            let trackingRadius = max(self.TRACKING_RADIUS, loc.radius);
            
            if distance < trackingRadius {
                trackingLocations.append(loc);
            }
            
            if distance < loc.radius {
                inLocations.append(loc);
            }
        }
        
        return (inLocations, trackingLocations);
    }
}