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
    
    static var timer: NSTimer = NSTimer()
    
    private override init()  {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LocationTracker.applicationEnterBackground), name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
    
    // MARK: Application in background
    func applicationEnterBackground() {
        LocationTracker.tracker.locationManager.startMonitoringVisits()
    }
    
    func updateLocation(){
        LocationTracker.tracker.locationManager.startUpdatingLocation()
    }
    
    func startLocationTracking() {
        print("startLocationTracking\n")
        LocationTracker.tracker.locationManager.delegate = LocationTracker.tracker
        LocationTracker.tracker.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        LocationTracker.tracker.locationManager.desiredAccuracy = kCLDistanceFilterNone
        
        if CLLocationManager.locationServicesEnabled() == false {
            print("locationServicesEnabled false\n")
            ErrorHandler.showEventsAcessDeniedAlert("Change Permissions", message: "Please change your location permissions to ")
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
            LocationTracker.tracker.locationManager.startUpdatingLocation()
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
        var newestLocation: CLLocation = locations[0] as CLLocation
        for oldLocation in locations {
            if oldLocation.timestamp.isGreaterThanDate(newestLocation.timestamp) {
                newestLocation = oldLocation
            }
        }
        print(newestLocation.horizontalAccuracy)
        LocationTracker.tracker.locationManager.stopUpdatingLocation()
        if let lat = newestLocation.coordinate.latitude as Double?, long = newestLocation.coordinate.longitude as Double?{
            LocationTracker.tracker.currentLocation = newestLocation
            LocationTracker.tracker.currentCoord = CLLocationCoordinate2DMake(lat, long)
            NSNotificationCenter.defaultCenter().postNotificationName(locationNotificationKey, object: self)
        } else {
            print("lat long not defined")
        }
    }
    
    func locationManager(manager: CLLocationManager, didVisit visit: CLVisit) {
        Location.storeLocation(visit.coordinate.latitude, lon: visit.coordinate.longitude, errorMargin: visit.horizontalAccuracy, arrivalTime: visit.arrivalDate, departureTime: visit.departureDate) {
            (res) in
        
                self.showNotification("Visit: \(res)")
            }
        Circle.addMemberToCircleByLocation(visit.coordinate.latitude, lon: visit.coordinate.longitude) {
            (res) in
                self.showNotification("added to room \(res["message"])")
        }
        showNotification("Visit: \(visit)")
        
    }
    
    
    func showNotification(body: String) {
        let notification = UILocalNotification()
        notification.alertAction = nil
        notification.alertBody = body
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }
}