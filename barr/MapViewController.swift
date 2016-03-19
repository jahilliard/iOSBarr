//
//  ViewController.swift
//  barr
//
//  Created by Justin Hilliard on 2/10/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import GoogleMaps

class MapViewController: UIViewController, GMSMapViewDelegate {
    
    var mapview: GMSMapView?
    
    var timer: NSTimer = NSTimer()
    var timeCount: Int = 0
    var previewView = UIView()

    var locationArr: [Location] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        let apiKey = "AIzaSyB0Ri7k31AAY9EjPXDhAQc1NpTzKaon6RM"
        GMSServices.provideAPIKey(apiKey)
        LocationTracker.tracker.startLocationTracking()
        if let lat = LocationTracker.tracker.currentCoord?.latitude, lon = LocationTracker.tracker.currentCoord?.longitude {
            mapview = makeMap(lat, longitude: lon , zoom: 16)
            self.view.addSubview(mapview!)
        } else {
            mapview = makeMap(40.4433, longitude: 79.9436 , zoom: 19)
            self.view.addSubview(mapview!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateMapLocation", name: locationNotificationKey, object: nil)
    }
    
    func makeMap(latitude: Double, longitude: Double, zoom: Float) -> GMSMapView {
        let camera = GMSCameraPosition.cameraWithLatitude(latitude,
            longitude: longitude, zoom: zoom)
        let mapView = GMSMapView.mapWithFrame(CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.view.frame.width, height: self.view.frame.height)), camera: camera)
        mapView.myLocationEnabled = true
        
        return mapView
    }
    
    func makeMarker(location: Location) -> GMSMarkerLocation {
        let marker = GMSMarkerLocation(location: location)
        marker.position = CLLocationCoordinate2DMake(location.lat as! Double, location.lon as! Double)
        marker.title = location.name
        return marker
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: locationNotificationKey, object: nil)
    }
    
    func updateMapLocation(){
        if let locationCoords = LocationTracker.tracker.currentCoord {
            mapview!.animateToLocation(locationCoords)
            Location.getLocations(locationCoords.latitude, lon: locationCoords.longitude, completion: {
                nearByLocations in
                for loc in nearByLocations {
                    let currMark = self.makeMarker(loc)
                    currMark.map = self.mapview
                }
            })
        }
    }
    
    func makePreviewView(locId: String){
        previewView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.view.frame.width, height: self.view.frame.height)))
        previewView.backgroundColor = UIColor.blackColor()
        previewView.alpha = 0.5
        self.view.addSubview(previewView)
        Circle.getPreview(locId)
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("previewTime:"), userInfo: nil, repeats: true)
    }
    
    func previewTime(sender: NSTimer!){
        print("test run")
        timeCount++
        if timeCount == 4 {
            self.timer.invalidate()
            timeCount = 0
            previewView.removeFromSuperview()
        }
    }
//    
//    func getLocation(){
//        
//            self.gMap.makeMap(lat, longitude: lon , zoom: 13) {
//                mapView in
//                    self.makeMap(mapView, hasUserLocation: true)
//                    Location.getLocations(lat, lon: lon) {
//                        response in
//                            let locs = response["locations"].arrayValue
//                            print(locs)
//                            for location in locs {
//                                let lo = Location(dictionary: location)
//                                let loCL = CLLocationCoordinate2DMake(lo.lat as! Double, lo.lon as! Double)
//                                let marker = self.gMap.makeMarker(lo)
//                                marker.map = mapView
//                                print(CLLocation.distance(LocationTracker.tracker.currentLocation!, to: loCL))
//                                self.locationArr.append(lo)
//                        }
//                    }
//                }
//        } else {
//            print("lat long not defined")
//            self.gMap.makeMap(40.4433, longitude: 79.9436 , zoom: 19) {
//                mapView in
//                    self.makeMap(mapView, hasUserLocation: false)
//            }
//        }
//    }
    
    func updateUserLocation(){

    }

    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        let markLoc = marker as! GMSMarkerLocation
        print(markLoc.location.id)
        makePreviewView(markLoc.location.id!)
        return true
    }
    


}

