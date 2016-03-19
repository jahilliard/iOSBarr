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
    
    
    func makeMap(latitude: Double, longitude: Double, zoom: Float) -> GMSMapView {
        let camera = GMSCameraPosition.cameraWithLatitude(latitude,
            longitude: longitude, zoom: zoom)
        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        mapView.myLocationEnabled = true
        
        return mapView
    }
    
    func makeMarker(location: Location) -> GMSMarkerLocation {
        let marker = GMSMarkerLocation(location: location)
        marker.position = CLLocationCoordinate2DMake(location.lat as! Double, location.lon as! Double)
        marker.title = location.name
        return marker
    }

    
}
