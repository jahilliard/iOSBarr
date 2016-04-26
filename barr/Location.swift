//
//  Location.swift
//  barr
//
//  Created by Justin Hilliard on 2/10/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import Foundation
import SwiftyJSON

class Location {
    var id: String
    var name: String
    var address: String?
    var imageURL: NSURL?
    var lat: Double
    var lon: Double
    var radius: Double
    
    init(id: String, name: String, lat: Double, lon: Double, radius: Double, address: String?, imageURL: NSURL?) {
        self.id = id;
        self.name = name;
        self.lat = lat;
        self.lon = lon;
        self.radius = radius;
        self.address = address;
        self.imageURL = imageURL;
    }
    
    static func getLocations(lat: Double, lon: Double, completion: (locations: [Location]) -> Void) {
        LocationTracker.tracker.nearbyLocations = [Location]()
        AlamoHelper.GET("api/v1/rooms/search/radius", parameters: ["location": [lon, lat], "radius":1600,
            "x_key": Me.user.userId!, "access_token": Me.user.accessToken!], completion: {
            err, response in
                if (err != nil) {
                    print(err);
                    //TODO: handle failure to get locations, maybe retry?
                    return;
                }
                
                let locs = response!["circles"].arrayValue
                for location in locs {
                    if let id = location["_id"].rawString(), name = location["properties"]["name"].rawString(), lat = location["geometry"]["coordinates"][1].double, lon = location["geometry"]["coordinates"][0].double, radius = location["properties"]["radius"].double
                    {
                        //TODO: add imageURL
                        let address = location["properties"]["address"].rawString();
                        let lo = Location(id: id, name: name, lat: lat, lon: lon, radius: radius, address: address, imageURL: nil);
                        LocationTracker.tracker.nearbyLocations.append(lo);
                    } else {
                        //break;
                    }
                }
                completion(locations: LocationTracker.tracker.nearbyLocations);
        })
    }
    
    static func storeLocation(lat: Double, lon: Double, errorMargin: Double, arrivalTime: NSDate, departureTime: NSDate){
        AlamoHelper.authorizedPost("usertracker/save", parameters: ["userId": Me.user.userId!, "latitude": lat, "longitude" : lon, "accuracyHorizontal": errorMargin, "arrivalTime": arrivalTime, "departureTime": departureTime]) {
            (err, response) in
            if (err != nil) {
                // Handle the Error
                return;
            } else {
                return;
            }
        }
    }
    
}