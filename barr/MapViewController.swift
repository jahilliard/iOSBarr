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
    
    // Mark: UIViewController Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let apiKey = "AIzaSyB0Ri7k31AAY9EjPXDhAQc1NpTzKaon6RM"
        GMSServices.provideAPIKey(apiKey)
        LocationTracker.tracker.startLocationTracking()
        if let lat = LocationTracker.tracker.currentCoord?.latitude, lon = LocationTracker.tracker.currentCoord?.longitude {
            mapview = makeMap(lat, longitude: lon , zoom: 15)
            self.view.addSubview(mapview!)
            updateMapLocation()
        } else {
            mapview = makeMap(40.4433, longitude: -79.9436 , zoom: 15)
            self.view.addSubview(mapview!)
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.updateMapLocation), name: locationNotificationKey, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
        if let picURL = Me.user.picturesArr {
            if picURL.count > 0 {
                print(picURL[0])
            }
        }
        mapview?.delegate = self
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: locationNotificationKey, object: nil)
    }
    
    // Mark: Map Methods
    
    func makeMap(latitude: Double, longitude: Double, zoom: Float) -> GMSMapView {
        let camera = GMSCameraPosition.cameraWithLatitude(latitude,
            longitude: longitude, zoom: 15)
        let mapView = GMSMapView.mapWithFrame(CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.view.frame.width, height: self.view.frame.height)), camera: camera)
        mapView.myLocationEnabled = true
        
        return mapView
    }
    
    func makeMarker(location: Location) -> GMSMarkerLocation {
        let marker = GMSMarkerLocation(location: location)
        marker.position = CLLocationCoordinate2DMake(location.lat as! Double, location.lon as! Double)
        marker.title = location.name
        marker.icon = UIImage(named: "map_pin")
        
        return marker
    }
    
    func updateMapLocation(){
        if let locationCoords = LocationTracker.tracker.currentCoord {
            mapview!.animateToLocation(locationCoords)
            Circle.addMemberToCircleByLocation(locationCoords.latitude, lon: locationCoords.longitude){
                _ in
                //ADD NOTIFICATION SAYING YOUR IN CIRCLE
            }
            Location.getLocations(locationCoords.latitude, lon: locationCoords.longitude, completion: {
                nearByLocations in
                for loc in nearByLocations {
                    print(loc)
                    let currMark = self.makeMarker(loc)
                    currMark.map = self.mapview
                }
            })
        }
    }
    
    // MARK: Delegate Methods

    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        let markLoc = marker as! GMSMarkerLocation
        print(markLoc.location.id)
        makePreviewView(markLoc.location.id!)
        return true
    }
    
    // MARK: Preview Methods
    
    func makePreviewView(locId: String){
        previewView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.view.frame.width, height: self.view.frame.height)))
        previewView.backgroundColor = UIColor.blackColor()
        previewView.alpha = 0.5
        self.view.addSubview(previewView)
        Circle.getPreview(locId)
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(MapViewController.previewTime(_:)), userInfo: nil, repeats: true)
    }
    
    func previewTime(sender: NSTimer!){
        print("test run")
        timeCount += 1
        if timeCount == 4 {
            self.timer.invalidate()
            timeCount = 0
            previewView.removeFromSuperview()
        }
    }

}

