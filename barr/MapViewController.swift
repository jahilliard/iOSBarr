//
//  ViewController.swift
//  barr
//
//  Created by Justin Hilliard on 2/10/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit
import CoreLocation
import FBSDKCoreKit
import SwiftyJSON

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    var gMap = GoogleMaps()
    
    var locationManager = CLLocationManager()
    
    var locationArr: [Location] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
    }
    
    func locationManager(manager: CLLocationManager){
        
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .NotDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .AuthorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
        case .AuthorizedAlways:
            locationManager.startUpdatingLocation()
            break
        case .Restricted:
            // restricted by e.g. parental controls. User can't enable Location Services
            break
        case .Denied:
            ErrorHandler.showEventsAcessDeniedAlert("Change Permissions", message: "Please change your location permissions")
            // user denied your app access to Location Services, but can grant access from Settings.app
            break
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error In Location Manager")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0] as CLLocation
        locationManager.stopUpdatingLocation()
        if let lat = userLocation.coordinate.latitude as Double?, long = userLocation.coordinate.longitude as Double?{
            self.gMap.makeMap(lat, longitude: long) {
                mapView in
                    self.view = mapView
                Location.getLocations(lat, lon: long) {
                    response in
                    let locs = response["locations"].arrayValue
                    for location in locs {
                        let lo = Location(dictionary: location)
                        let marker = self.gMap.makeMarker(lo)
                        marker.map = mapView
                        self.locationArr.append(lo)
                    }
                    
                }
            }
        } else {
            print("lat long not defined")
        }
    }

}

