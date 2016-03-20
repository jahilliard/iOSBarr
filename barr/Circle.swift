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

class Circle {
    let locationId : String?;
    var members : [String: UserInfo];
    
    init(dictionary: NSDictionary) {
        self.locationId = dictionary["businessId"] as? String;
        let members = dictionary["members"] as? [NSDictionary];
        
        self.members = [String: UserInfo]();
        if (members != nil){
            for dictionary in members!{
                let dicJSON = JSON(dictionary)
                let singleMember = UserInfo(userInfo: dicJSON["userInfo"]);
                self.members[singleMember.userId] = singleMember;
            }
        }
    }
    
    static func addMemberToCircleByLocation(lat: Double, lon: Double){
        let subdomain = "/api/v1/rooms/members/" + Me.user.userId!
        AlamoHelper.authorizedPost(subdomain, parameters: ["coordinate" : [lon, lat]], completion: {
            response in
            print("add member by location");
        })
    }
    
    func addMember(dictionary: NSDictionary) {
        let dicJSON = JSON(dictionary)
        let singleMember = UserInfo(userInfo: dicJSON["userInfo"]);
        self.members[singleMember.userId] = singleMember;
    }
    
    func deleteMember(userId: String){
        self.members.removeValueForKey(userId);
    }
    
    static func getPreview(locationId : String) -> [String]{
        var picArr: [String]
        AlamoHelper.GET("api/v1/room/locations/" + locationId, parameters: ["x_key": Me.user.userId!, "access_token": Me.user.accessToken!], completion: {
            result in
            print(result)
            if let member = result["room"]["members"].arrayObject {
                let rand = Int(arc4random_uniform(UInt32(member.count)))
                print(member)
                
            }
        })
        return []
    }
}