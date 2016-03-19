//
//  DownImage.swift
//  barr
//
//  Created by Justin Hilliard on 3/5/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

struct DownloadImage {
    static func downloadImage(url: NSURL, completion: (UIImage) -> Void){
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                if let img = UIImage(data: data) {
                    completion(img)
                } else {
                    print("error with making img")
                }
            }
        }
    }
    
    private static func getDataFromUrl(url: NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
}
