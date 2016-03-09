//
//  FacebookPhotoCellInfo.swift
//  barr
//
//  Created by Justin Hilliard on 3/8/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

class FacebookPhotoCellInfo {
    let imgURL: String
    let pictId: String
    let img: UIImage
    let indexPath: NSIndexPath
    
    var hasBorder: Bool = false
    var selPhotoIndex: Int = -1

    init (imgURL: String, pictId: String, img: UIImage, indexPath: NSIndexPath){
        self.imgURL = imgURL
        self.pictId = pictId
        self.img = img
        self.indexPath = indexPath
    }
    
}
