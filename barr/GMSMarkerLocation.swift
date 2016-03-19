//
//  GMSMarkerLocation.swift
//  barr
//
//  Created by Justin Hilliard on 3/10/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit
import GoogleMaps

class GMSMarkerLocation: GMSMarker {
    let location: Location
    
    init(location: Location) {
        self.location = location
        super.init()
    }
}