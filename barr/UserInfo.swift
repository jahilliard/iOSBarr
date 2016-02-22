//
//  UserInfo.swift
//  barr
//
//  Created by Justin Hilliard on 2/21/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class UserInfo {
    let userId : String?;
    let nickname : String?;
    let firstName: String?;
    let lastName: String?;
    let img: String?
    
    init(dictionary: NSDictionary) {
        self.userId = dictionary["userId"] as? String;
        self.nickname = dictionary["nickname"] as? String;
        self.firstName = dictionary["firstName"] as? String;
        self.lastName = dictionary["lastName"] as? String;
        self.img = dictionary["img"] as? String;
    }
}
