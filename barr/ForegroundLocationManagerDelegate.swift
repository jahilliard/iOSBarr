//
//  ForegroundLocationManagerDelegate.swift
//  barr
//
//  Created by Carl Lin on 4/27/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class ForegroundLocationManagerDelegate : NSObject, CLLocationManagerDelegate, CoordinateDelegate {
    var locationUpdateTimer : NSTimer! = nil;
    var UPDATE_INTERVAL : Double = 30;
    //guard to make limit to one didupdatelocation call per call to startUpdatingLocation()
    var gotUpdatedCoordinate: Bool = false;
    
    override init() {
        super.init();
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleNewLocations), name: updatedNearbyLocationsNotification, object: nil);
    }
    
    func close(){
        if locationUpdateTimer != nil {
            self.stopFineGrainedLocationTimer();
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    func updateLocation(){
        self.updateCoordinates();
    }
    
    func startFineGrainedLocationTimer(){
        self.updateCoordinates();
        self.locationUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(UPDATE_INTERVAL, target: self, selector: #selector(self.updateLocation), userInfo: nil, repeats: true);
    }
    
    func handleNewLocations(){
        if locationUpdateTimer == nil {
            startFineGrainedLocationTimer();
        }
    }
    
    func stopFineGrainedLocationTimer(){
        if self.locationUpdateTimer != nil {
            self.locationUpdateTimer.invalidate();
            self.locationUpdateTimer = nil;
        }
    }
    
    func handleForegroundUpdate(newestLocation: CLLocation) {
        LocationTracker.sharedInstance.locationManager.stopUpdatingLocation();
        //tell listeners about new current coordinate
        NSNotificationCenter.defaultCenter().postNotificationName(updatedCoordinateNotificationKey, object: self, userInfo: ["newLocation": newestLocation]);
        
        self.checkIfShouldAddUserToNearbyCircle();
    }
    
    func checkIfShouldAddUserToNearbyCircle(){
        if let currentLocation = LocationTracker.sharedInstance.currentLocation, lat = currentLocation.coordinate.latitude as Double?, long = currentLocation.coordinate.longitude as Double?
        {
            if (Circle.sharedInstance.coordinates != nil && Circle.sharedInstance.coordinates.distanceFromLocation(currentLocation) < Circle.sharedInstance.radius)
            {
                //stop checking locations
                self.stopFineGrainedLocationTimer();
            } else {
                //check if in location, if so, add to that location and stop checking locations
                let result = LocationTracker.sharedInstance.getContainingRegions(currentLocation);
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
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error);
        print("Error In Location Manager")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if self.gotUpdatedCoordinate {
            return;
        }
        
        self.gotUpdatedCoordinate = true;
        var newestLocation: CLLocation = locations[0] as CLLocation
        for oldLocation in locations {
            if oldLocation.timestamp.isGreaterThanDate(newestLocation.timestamp) {
                newestLocation = oldLocation
            }
        }
        
        self.handleForegroundUpdate(newestLocation);
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
        print(region.identifier);
        if self.locationUpdateTimer == nil {
            self.startFineGrainedLocationTimer();
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
    
    
    func locationManager(manager: CLLocationManager, didVisit visit: CLVisit) {
        showNotification("Visit: \(visit)")
        LocationTracker.sharedInstance.getCircleLocationInfo(CLLocation(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude));
        /*Location.storeLocation(visit.coordinate.latitude, lon: visit.coordinate.longitude, errorMargin: visit.horizontalAccuracy, arrivalTime: visit.arrivalDate, departureTime: visit.departureDate);*/
    }
    
    //MARK: CoordinateDelegate delegate start
    func updateCoordinates() {
        self.gotUpdatedCoordinate = false;
        LocationTracker.sharedInstance.locationManager.startUpdatingLocation();
    }
    
    func showNotification(body: String) {
        let notification = UILocalNotification()
        notification.alertAction = nil
        notification.alertBody = body
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }
}