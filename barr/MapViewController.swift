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
import Alamofire

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    var gMap = GoogleMaps()
    
    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(FBSDKAccessToken.currentAccessToken().refreshDate)")
        print("\(FBSDKAccessToken.currentAccessToken().tokenString)")
        FBSDKAccessToken.refreshCurrentAccessToken( {
            (connection, result, error : NSError!) -> Void in
            print("\(error)")
            print("\(result.tokenString)")
            print("\(FBSDKAccessToken.currentAccessToken().refreshDate)")
        })
        print("\(FBSDKAccessToken.currentAccessToken().refreshDate)")
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            print("request auth")
            locationManager.requestAlwaysAuthorization()
        } else {
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("status")
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
            // user denied your app access to Location Services, but can grant access from Settings.app
            break
        default:
            break
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0] as CLLocation
        locationManager.stopUpdatingLocation()
        if let lat = userLocation.coordinate.latitude as Double?, long = userLocation.coordinate.longitude as Double?{
            let button = UIButton(frame: CGRectMake((screenSize.width * 0.75), (screenSize.height * 0.75), screenSize.width * 0.1, screenSize.height * 0.1))
            button.backgroundColor = UIColor.greenColor()
            self.view = self.gMap.makeMap(lat, longitude: long)
            self.view.addSubview(button)
            ErrorHandler.buidErrorView(true)
        }else {
            print("lat long not defined")
        }
    }

}

