//
//  BackgroundLocationManagerDelegate.swift
//  barr
//
//  Created by Carl Lin on 4/26/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class BackgroundLocationManagerDelegate : NSObject, CLLocationManagerDelegate, CoordinateDelegate {
    static var sharedInstance: BackgroundLocationManagerDelegate = BackgroundLocationManagerDelegate();
    var locationUpdateTimer : NSTimer! = nil;
    var UPDATE_INTERVAL : Double = 30;
    var needAccurateReading : Bool = false;
    var DESIRED_ACCURACY : Double = 20.0
    
    
    override init() {
        super.init();
        LocationTracker.sharedInstance.locationManager.desiredAccuracy =  kCLLocationAccuracyThreeKilometers;
        LocationTracker.sharedInstance.locationManager.startUpdatingLocation();
        self.startFineGrainedLocationTimer();
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleNewLocations), name: updatedNearbyLocationsNotification, object: nil);
    }
    
    func close(){
        if self.locationUpdateTimer != nil {
            self.locationUpdateTimer.invalidate();
            self.locationUpdateTimer = nil;
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    func startFineGrainedLocationTimer(){
        self.updateCoordinates();
        self.locationUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(UPDATE_INTERVAL, target: self, selector: #selector(self.updateCoordinates), userInfo: nil, repeats: true);
    }
    
    func stopFineGrainedLocationTimer(){
        if self.locationUpdateTimer != nil {
            self.locationUpdateTimer.invalidate();
            self.locationUpdateTimer = nil;
        }
    }
    
    func handleNewLocations(){
        if locationUpdateTimer == nil {
            startFineGrainedLocationTimer();
        }
    }
    
    func handleBackgroundUpdate(newestLocation: CLLocation) {
        if let lat = newestLocation.coordinate.latitude as Double?, long = newestLocation.coordinate.longitude as Double?{
            
            //  Location.storeLocation(lat, lon: long, errorMargin: newestLocation.horizontalAccuracy, arrivalTime: NSDate.now(), departureTime: NSDate.now());
            if newestLocation.horizontalAccuracy > self.DESIRED_ACCURACY {
                return;
            }
            
            if needAccurateReading {
                //power down GPS
                LocationTracker.sharedInstance.locationManager.desiredAccuracy =  kCLLocationAccuracyThreeKilometers;
                LocationTracker.sharedInstance.currentLocation = newestLocation;
                LocationTracker.sharedInstance.currentCoord = CLLocationCoordinate2DMake(lat, long);
                
                self.checkIfShouldAddUserToNearbyCircle(newestLocation);
                self.needAccurateReading = false;
                NSNotificationCenter.defaultCenter().postNotificationName(updatedCoordinateNotificationKey, object: self, userInfo: ["newLocation": newestLocation]);
            }
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
                let result = LocationTracker.sharedInstance.getContainingRegions(newestLocation);
                let inLocations = result.0;
                let trackingLocations = result.1;
                if trackingLocations.count == 0 {
                    self.stopFineGrainedLocationTimer();
                }
                
                if inLocations.count > 0 {
                    Circle.addMemberToCircleByLocation(lat, lon: long, callback: {err in
                        if err != nil && err!.domain != "Voluntary Cancel" {
                            self.startFineGrainedLocationTimer();
                        }
                    });
                    self.stopFineGrainedLocationTimer();
                }
                
                if trackingLocations.count > 0 && inLocations.count == 0 && self.locationUpdateTimer == nil{
                    self.startFineGrainedLocationTimer();
                }
            }
        }
    }
    
    //MARK: CLLocationManager delegate begin
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print(region.identifier);
        if self.locationUpdateTimer == nil {
            self.startFineGrainedLocationTimer();
        }
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region.identifier == LocationTracker.sharedInstance.SEARCH_REGION_IDENTIFIER {
            LocationTracker.sharedInstance.getFreshLocationInfo();
            return;
        }
        
        if self.locationUpdateTimer == nil {
            self.startFineGrainedLocationTimer();
        }
        
        if (Circle.sharedInstance.circleId != region.identifier) {
            return;
        }
        
        /*Circle.deleteMemberFromCircleByID(region.identifier) {
            (err, res) in
            if err != nil {
                //TODO:
            } else {
                print(res)
            }
        }*/
        
        print("Did get ready to exit region \(region)")
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .NotDetermined:
            LocationTracker.sharedInstance.locationManager.requestAlwaysAuthorization()
            break
        case .AuthorizedWhenInUse:
            ErrorHandler.showEventsAcessDeniedAlert("Change Permissions", message: "Please change your location permissions to Always")
            break
        case .AuthorizedAlways:
            self.updateCoordinates();
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
    
    func locationManager(manager: CLLocationManager, didVisit visit: CLVisit) {
        showNotification("Visit: \(visit)")
        LocationTracker.sharedInstance.getCircleLocationInfo(CLLocation(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude));
        /*Location.storeLocation(visit.coordinate.latitude, lon: visit.coordinate.longitude, errorMargin: visit.horizontalAccuracy, arrivalTime: visit.arrivalDate, departureTime: visit.departureDate);*/
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error In Location Manager")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var newestLocation: CLLocation = locations[0] as CLLocation
        for oldLocation in locations {
            if oldLocation.timestamp.isGreaterThanDate(newestLocation.timestamp) {
                newestLocation = oldLocation
            }
        }
        
        self.handleBackgroundUpdate(newestLocation);
    }
    
    //MARK: CoordinateDelegate delegate start
    func updateCoordinates() {
        LocationTracker.sharedInstance.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.needAccurateReading = true;
        LocationTracker.sharedInstance.locationManager.startUpdatingLocation();
    }
    
    func showNotification(body: String) {
        let notification = UILocalNotification()
        notification.alertAction = nil
        notification.alertBody = body
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }
}