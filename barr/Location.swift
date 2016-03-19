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
    
//        //setting address
//        var address = ""
//        if let location = dictionary["location"].rawValue as? NSDictionary {
//            let addressArray = location["address"] as? NSArray
//            if addressArray != nil && addressArray!.count > 0 {
//                address = addressArray![0] as! String
//            }
//            
//            let neighborhoods = location["neighborhoods"] as? NSArray
//            if neighborhoods != nil && neighborhoods!.count > 0 {
//                if !address.isEmpty {
//                    address += ", "
//                }
//                address += neighborhoods![0] as! String
//            }
//        }
        
//        //setting categories
//        let categoriesArray = dictionary["categories"].rawValue as? [[String]]
//        if categoriesArray != nil {
//            var categoryNames = [String]()
//            for category in categoriesArray! {
//                let categoryName = category[0]
//                categoryNames.append(categoryName)
//            }
//            self.categories = categoryNames.joinWithSeparator(", ")
//        } else {
//            self.categories = nil
//        }
//        
//        //setting distance
//        if let distanceMeters = dictionary["distance"].rawValue as? NSNumber {
//            let milesPerMeter = 0.000621371
//            self.distance = String(format: "%.2f mi", milesPerMeter * distanceMeters.doubleValue)
//        } else {
//            self.distance = nil
//        }
//        
//        //setting ratingImageURL
//        if let ratingImageURLString = dictionary["rating_img_url_large"].rawString() {
//            self.ratingImageURL = NSURL(string: ratingImageURLString)
//        } else {
//            self.ratingImageURL = nil
//        }
//        
//        reviewCount = dictionary["review_count"].rawValue as? NSNumber
    
    static func getLocations(lat: Double, lon: Double, completion: (response: JSON) -> Void) {
        AlamoHelper.GET("api/v1/locations/search/radius", parameters: ["location": [lon, lat], "radius":100000,
            "x_key": Me.user.userId!, "access_token": Me.user.accessToken!], completion: {
            response in
                completion(response: response)
        })
    }
    
}