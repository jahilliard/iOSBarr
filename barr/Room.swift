//
//  Room.swift
//  barr
//
//  Created by Justin Hilliard on 2/10/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class Room {
    let businessId : String?;
    var members : [String: UserInfo];
    
    init(dictionary: NSDictionary) {
        self.businessId = dictionary["businessId"] as? String;
        let members = dictionary["members"] as? [NSDictionary];
        
        self.members = [String: UserInfo]();
        if (members != nil){
            for dictionary in members!{
                let singleMember = UserInfo(userId: dictionary["userInfo"]!["userId"] as! String, nickname: dictionary["userInfo"]!["nickname"] as! String, firstName: dictionary["userInfo"]!["firstName"] as! String, lastName: dictionary["userInfo"]!["lastName"] as! String, img: dictionary["userInfo"]!["img"] as! String)
                self.members[singleMember.userId] = singleMember;
            }
        }
    }
    
    func addMember(dictionary: NSDictionary) {
        let singleMember = UserInfo(userId: dictionary["userInfo"]!["userId"] as! String, nickname: dictionary["userInfo"]!["nickname"] as! String, firstName: dictionary["userInfo"]!["firstName"] as! String, lastName: dictionary["userInfo"]!["lastName"] as! String, img: dictionary["userInfo"]!["img"] as! String);
        self.members[singleMember.userId] = singleMember;
    }
    
    func deleteMember(userId: String){
        self.members.removeValueForKey(userId);
    }
}