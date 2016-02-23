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
    
    init(userId: String, nickname: String, firstName: String, lastName: String, img: String) {
        self.userId = userId;
        self.nickname = nickname;
        self.firstName = firstName;
        self.lastName = lastName;
        self.img = img;
    }
}
