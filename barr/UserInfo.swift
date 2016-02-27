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
    let userId : String;
    let nickname : String;
    let firstName: String;
    let lastName: String;
    let img: String;
    
    enum sentRequest {
        case Nothing
        case heart
        case heartDrink
        case Drink
    }
    
    enum pendingRequest {
        case Nothing
        case heart
        case heartDrink
        case Drink
    }
    
    init(userInfo: JSON) {
        if let userId = userInfo["userId"].rawString(), nickname = userInfo["nickname"].rawString(), firstName = userInfo["firstName"].rawString(), lastName = userInfo["lastName"].rawString(), img = userInfo["img"].rawString() {
            self.userId = userId;
            self.nickname = nickname;
            self.firstName = firstName;
            self.lastName = lastName;
            self.img = img;
        } else {
            print("User Values not defined")
            self.userId = "userId";
            self.nickname = "nickname";
            self.firstName = "firstName";
            self.lastName = "lastName";
            self.img = "img";
        }
    }
}
