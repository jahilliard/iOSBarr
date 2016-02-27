//
//  Business.swift
//  barr
//
//  Created by Justin Hilliard on 2/10/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import Foundation
import SwiftyJSON

class Location {
    let name: String?
    let address: String?
    let imageURL: NSURL?
    let categories: String?
    let distance: String?
    let ratingImageURL: NSURL?
    let reviewCount: NSNumber?
    let lat: NSNumber?
    let lon: NSNumber?
    
    init(dictionary: JSON) {
        self.name = dictionary["name"].rawString()
        self.lat = dictionary["lat"].rawValue as? NSNumber
        self.lon = dictionary["lon"].rawValue as? NSNumber
        
        
        //setting imageURL
        if let imageURLString = dictionary["image_url"].rawString() {
            self.imageURL = NSURL(string: imageURLString)!
        } else {
            self.imageURL = nil
        }
        
        //setting address
        var address = ""
        if let location = dictionary["location"].rawValue as? NSDictionary {
            let addressArray = location["address"] as? NSArray
            if addressArray != nil && addressArray!.count > 0 {
                address = addressArray![0] as! String
            }
            
            let neighborhoods = location["neighborhoods"] as? NSArray
            if neighborhoods != nil && neighborhoods!.count > 0 {
                if !address.isEmpty {
                    address += ", "
                }
                address += neighborhoods![0] as! String
            }
        }
        self.address = address
        
        //setting categories
        let categoriesArray = dictionary["categories"].rawValue as? [[String]]
        if categoriesArray != nil {
            var categoryNames = [String]()
            for category in categoriesArray! {
                let categoryName = category[0]
                categoryNames.append(categoryName)
            }
            self.categories = categoryNames.joinWithSeparator(", ")
        } else {
            self.categories = nil
        }
        
        //setting distance
        if let distanceMeters = dictionary["distance"].rawValue as? NSNumber {
            let milesPerMeter = 0.000621371
            self.distance = String(format: "%.2f mi", milesPerMeter * distanceMeters.doubleValue)
        } else {
            self.distance = nil
        }
        
        //setting ratingImageURL
        if let ratingImageURLString = dictionary["rating_img_url_large"].rawString() {
            self.ratingImageURL = NSURL(string: ratingImageURLString)
        } else {
            self.ratingImageURL = nil
        }
        
        reviewCount = dictionary["review_count"].rawValue as? NSNumber
    }
    
    func getLocations(completion: (response: JSON) -> Void){
        AlamoHelper.GET("locations/", parameters: nil, completion: {
            response in
                completion(response: response)
        })
    }
    
}