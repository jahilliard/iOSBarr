//
//  GoogleClient.swift
//  barr
//
//  Created by Justin Hilliard on 2/12/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit
import GoogleMaps

class GoogleMaps {
    
    let gMapsAPIKey = "AIzaSyB0Ri7k31AAY9EjPXDhAQc1NpTzKaon6RM"
    
    init() {
        GMSServices.provideAPIKey(self.gMapsAPIKey)
    }
    
    func makeMap(latitude: Double, longitude: Double) -> UIView{
        let camera = GMSCameraPosition.cameraWithLatitude(latitude,
            longitude: longitude, zoom: 13)
        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        mapView.myLocationEnabled = true
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(-33.86, 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
        
        return mapView
    }
}
