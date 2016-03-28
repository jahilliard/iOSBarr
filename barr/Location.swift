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
    var id: String?
    var name: String?
    var address: String?
    var imageURL: NSURL?
    var lat: NSNumber?
    var lon: NSNumber?
    
    static var nearbyLocations: [Location] = [Location]()
    
    init(dictionary: JSON) {
        if let id = dictionary["_id"].rawString() {
            self.id = id
        }
        if let name = dictionary["properties"]["name"].rawString() {
            self.name = name
        }
        if let lat = dictionary["geometry"]["coordinates"][1].rawValue as? NSNumber {
            self.lat = lat
        }
        if let lon = dictionary["geometry"]["coordinates"][0].rawValue as? NSNumber {
            self.lon = lon
        }
        if let address = dictionary["address"].rawString() {
            self.address = address
        }
        
        //setting imageURL
        if let imageURLString = dictionary["image_url"].rawString() {
            self.imageURL = NSURL(string: imageURLString)!
        }
    }
    
    static func getLocations(lat: Double, lon: Double, completion: (locations: [Location]) -> Void) {
        nearbyLocations = [Location]()
        AlamoHelper.GET("api/v1/locations/search/radius", parameters: ["location": [lon, lat], "radius":100000,
            "x_key": Me.user.userId!, "access_token": Me.user.accessToken!], completion: {
            err, response in
                if (err != nil) {
                    print(err);
                    //TODO: handle failure to get locations, maybe retry?
                    return;
                }
                
                let locs = response!["locations"].arrayValue
                for location in locs {
                    let lo = Location(dictionary: location)
                    Location.nearbyLocations.append(lo)
                }
                completion(locations: nearbyLocations)
        })
    }
    
}