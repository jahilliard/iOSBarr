//
//  Business.swift
//  barr
//
//  Created by Justin Hilliard on 2/10/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import Foundation
import Alamofire
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
    
    init(dictionary: NSDictionary) {
        self.name = dictionary["name"] as? String
        self.lat = dictionary["lat"] as? NSNumber
        self.lon = dictionary["lon"] as? NSNumber
        
        //setting imageURL
        let imageURLString = dictionary["image_url"] as? String
        if imageURLString != nil {
            self.imageURL = NSURL(string: imageURLString!)!
        } else {
            self.imageURL = nil
        }
        
        let location = dictionary["location"] as? NSDictionary
        
        //setting address
        var address = ""
        if location != nil {
            let addressArray = location!["address"] as? NSArray
            if addressArray != nil && addressArray!.count > 0 {
                address = addressArray![0] as! String
            }
            
            let neighborhoods = location!["neighborhoods"] as? NSArray
            if neighborhoods != nil && neighborhoods!.count > 0 {
                if !address.isEmpty {
                    address += ", "
                }
                address += neighborhoods![0] as! String
            }
        }
        self.address = address
        
        //setting categories
        let categoriesArray = dictionary["categories"] as? [[String]]
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
        let distanceMeters = dictionary["distance"] as? NSNumber
        if distanceMeters != nil {
            let milesPerMeter = 0.000621371
            self.distance = String(format: "%.2f mi", milesPerMeter * distanceMeters!.doubleValue)
        } else {
            self.distance = nil
        }
        
        //setting ratingImageURL
        let ratingImageURLString = dictionary["rating_img_url_large"] as? String
        if ratingImageURLString != nil {
            self.ratingImageURL = NSURL(string: ratingImageURLString!)
        } else {
            self.ratingImageURL = nil
        }
        
        reviewCount = dictionary["review_count"] as? NSNumber
    }
    
}