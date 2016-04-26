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

let locationNotificationKey = "com.barrapp.locationUpdated"

class LocationTracker : NSObject, CLLocationManagerDelegate {
    
    static var tracker: LocationTracker = LocationTracker()
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var currentCoord: CLLocationCoordinate2D?
    //guard to make limit to one didupdatelocation call per call tostartUpdatingLocation()
    var didFindLocation: Bool = false;
    var needsRefresh: Bool = false;
    var nearbyLocations: [Location] = [];
    var locationUpdateTimer : NSTimer! = nil;
    var UPDATE_INTERVAL : Double = 30;
    var TRACKING_RADIUS : Double = 200;
    
    func startFineGrainedLocationTimer(){
        self.locationUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(UPDATE_INTERVAL, target: self, selector: #selector(self.updateLocation), userInfo: nil, repeats: true);
    }
    
    func stopFineGrainedLocationTimer(){
        if self.locationUpdateTimer != nil {
            self.locationUpdateTimer.invalidate();
            self.locationUpdateTimer = nil;
        }
    }

    func getContainingRegions(coord : CLLocation) -> ([Location], [Location]){
        var inLocations = [Location]();
        var trackingLocations = [Location]();
        for loc in nearbyLocations {
            let distance = coord.distanceFromLocation(CLLocation(latitude: loc.lat, longitude: loc.lon))
            let trackingRadius = max(TRACKING_RADIUS, loc.radius);
            
            if distance < trackingRadius {
                trackingLocations.append(loc);
            }
            
            if distance < loc.radius {
                inLocations.append(loc);
            }
        }
        
        return (inLocations, trackingLocations);
    }
    
    func registerRegionsToMonitor(nearbyLocations: [Location]){ 
        stopMonitoringRegions()
        for loc in nearbyLocations {
            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: CLLocationDegrees(loc.lat), longitude: CLLocationDegrees(loc.lon)), radius: max(TRACKING_RADIUS, loc.radius), identifier: loc.id);
            region.notifyOnEntry = true;
            region.notifyOnExit = true;
            print("monitoring region \(region)")
            LocationTracker.tracker.locationManager.startMonitoringForRegion(region);
        }
    }
    
    func stopMonitoringRegions(){
        for region in self.locationManager.monitoredRegions {
            LocationTracker.tracker.locationManager.stopMonitoringForRegion(region);
        }
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        //Me.user.leaveCurrentCircle()
        if self.locationUpdateTimer == nil {
            self.startFineGrainedLocationTimer();
        }
        
        if (Circle.sharedInstance.circleId != region.identifier) {
            return;
        }
        
        Circle.deleteMemberFromCircleByID(region.identifier) {
            (err, res) in
            if err != nil {
                //TODO:
            } else {
                print(res)
                self.showNotification("left to room \(res!["message"])")
            }
        }
        
        print("Did get ready to exit region \(region)")
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if self.locationUpdateTimer == nil {
            self.startFineGrainedLocationTimer();
        }
        
        if (UIApplication.sharedApplication().applicationState == UIApplicationState.Background) {
            
        } else {
            
        }
        //Me.user.resetCurrentCircle(region.identifier)
        /*if Circle.sharedInstance.circleId != "" && region.identifier != Circle.sharedInstance.circleId {
            return;
        }
        
        Circle.addMemberToCircleByID(region.identifier) {
            (err, circleId) in
            if (err != nil) {
                //TODO: handle
            } else {
                self.showNotification("added the room \(circleId)")
            }
        }
        
        print("Did get ready to enter region \(region)")*/
        
    }
    
    private override init()  {
        super.init()
    }
    
    func updateLocation(){
        self.didFindLocation = false
        LocationTracker.tracker.locationManager.startUpdatingLocation()
    }
    
    func startLocationTracking() {
        self.needsRefresh = true;
        //initialize locationManager
        LocationTracker.tracker.locationManager.delegate = LocationTracker.tracker
        LocationTracker.tracker.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        LocationTracker.tracker.locationManager.distanceFilter = kCLDistanceFilterNone;
        LocationTracker.tracker.locationManager.allowsBackgroundLocationUpdates = true;
        if CLLocationManager.locationServicesEnabled() == false {
            print("locationServicesEnabled false\n")
            ErrorHandler.showEventsAcessDeniedAlert("Change Permissions", message: "Please change your location permissions to Always")
        } else {
            CLLocationManager.authorizationStatus()
        }
    }
    
    //MARK: Location Delegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .NotDetermined:
            LocationTracker.tracker.locationManager.requestAlwaysAuthorization()
            break
        case .AuthorizedWhenInUse:
            ErrorHandler.showEventsAcessDeniedAlert("Change Permissions", message: "Please change your location permissions to Always")
            break
        case .AuthorizedAlways:
            self.updateLocation();
            break
        case .Restricted:
            // restricted by e.g. parental controls. User can't enable Location Services
            ErrorHandler.showEventsAcessDeniedAlert("Change Permissions", message: "Please change your location permissions to ")
            break
        case .Denied:
            ErrorHandler.showEventsAcessDeniedAlert("Change Permissions", message: "Please change your location permissions to Always")
            // user denied your app access to Location Services, but can grant access from Settings.app
            break
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error In Location Manager")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if self.didFindLocation {
            return;
        }
        
        self.didFindLocation = true;
        var newestLocation: CLLocation = locations[0] as CLLocation
        for oldLocation in locations {
            if oldLocation.timestamp.isGreaterThanDate(newestLocation.timestamp) {
                newestLocation = oldLocation
            }
        }
        LocationTracker.tracker.locationManager.stopUpdatingLocation();
        if let lat = newestLocation.coordinate.latitude as Double?, long = newestLocation.coordinate.longitude as Double?{
            
//            Location.storeLocation(lat, lon: long, errorMargin: newestLocation.horizontalAccuracy, arrivalTime: NSDate.now(), departureTime: NSDate.now());
            
            LocationTracker.tracker.currentLocation = newestLocation
            LocationTracker.tracker.currentCoord = CLLocationCoordinate2DMake(lat, long)
            
            //update current coordinates on map
            NSNotificationCenter.defaultCenter().postNotificationName(locationNotificationKey, object: self)
            
            if self.needsRefresh {
                self.needsRefresh = false;
                self.getCircleInfo(newestLocation);
                return;
            }
            
            self.checkIfShouldAddUserToNearbyCircle(newestLocation);
        } else {
            print("lat long not defined")
        }
    }
    
    func checkIfShouldAddUserToNearbyCircle(newestLocation : CLLocation){
        if let lat = newestLocation.coordinate.latitude as Double?, long = newestLocation.coordinate.longitude as Double?
        {
            if (Circle.sharedInstance.coordinates != nil && Circle.sharedInstance.coordinates.distanceFromLocation(newestLocation) < Circle.sharedInstance.radius)
            {
                //stop checking locations
                self.stopFineGrainedLocationTimer();
            } else {
                //check if in location, if so, add to that location and stop checking locations
                let result = getContainingRegions(newestLocation);
                let inLocations = result.0;
                let trackingLocations = result.1;
                if trackingLocations.count == 0 {
                    self.stopFineGrainedLocationTimer();
                }
                
                if inLocations.count > 0 {
                    Circle.addMemberToCircleByLocation(lat, lon: long);
                    self.stopFineGrainedLocationTimer();
                }
                
                if trackingLocations.count > 0 && inLocations.count == 0 && self.locationUpdateTimer == nil{
                    self.startFineGrainedLocationTimer();
                }
            }
        }
    }
    
    /*func locationManager(manager: CLLocationManager, didVisit visit: CLVisit) {
        showNotification("Visit: \(visit)")
        Location.getLocations(visit.coordinate.latitude, lon: visit.coordinate.longitude, completion: {
            nearByLocations in
            self.registerRegionsToMonitor(nearByLocations);
        });
        Location.storeLocation(visit.coordinate.latitude, lon: visit.coordinate.longitude, errorMargin: visit.horizontalAccuracy, arrivalTime: visit.arrivalDate, departureTime: visit.departureDate);
    }*/
    
    
    
    func getCircleInfoOnReconnect() {
        self.needsRefresh = true;
        self.updateLocation();
    }
    
    func getCircleInfo(newestLocation: CLLocation){
        if let lat = newestLocation.coordinate.latitude as Double?, long = newestLocation.coordinate.longitude as Double?
        {
            Location.getLocations(lat, lon: long, completion: {
                nearByLocations in
                //update nearby locations on map
                NSNotificationCenter.defaultCenter().postNotificationName(locationNotificationKey, object: self);
                self.registerRegionsToMonitor(nearByLocations);
                self.checkIfShouldAddUserToNearbyCircle(newestLocation);
            });
        }
    }
    
    func showNotification(body: String) {
        let notification = UILocalNotification()
        notification.alertAction = nil
        notification.alertBody = body
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }
}