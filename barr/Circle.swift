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
    var locationId : String?;
    var circleId: String?;
    var members : [String: UserInfo] = [String: UserInfo]();
    static let sharedInstance : Circle = Circle();
    
    private init(){}
    
    func initCircle(dictionary: JSON) {
        self.circleId = dictionary["circleId"].string;
        let members = dictionary["members"].arrayValue;
        
        self.members = [String: UserInfo]();
        for userInfo in members{
            print(userInfo["_id"].string);
            let singleMember = UserInfo(userInfo: userInfo);
            self.members[singleMember.userId] = singleMember;
        }
        
        print("MEMBERS");
        print(self.members);
    }
    
    static func addMemberToCircleByLocation(lat: Double, lon: Double){
        let subdomain = "api/v1/rooms/members/" + Me.user.userId!
        AlamoHelper.authorizedPost(subdomain, parameters: ["coordinate" : [lon, lat]], completion: {
            err, response in
            if (err != nil) {
                //TODO: handle
                return;
            }
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
    
    func getCircleInfo(){
        let subdomain = "api/v1/users/\(Me.user.userId!)/circle/";

        AlamoHelper.authorizedGet(subdomain, parameters: [String: AnyObject](), completion: {err, result in
            if (err != nil){
                //TODO: handle this better
                self.getCircleInfo();
                return;
            }
                
            else if (result!["message"].string != "success") {
                self.getCircleInfo();
                return;
            }
                
            else {
                self.initCircle(result!["data"]);
            }
        });
    }
    
    static func getPreview(locationId : String) -> [String]{
        var picArr: [String]
        AlamoHelper.GET("api/v1/room/locations/" + locationId, parameters: ["x_key": Me.user.userId!, "access_token": Me.user.accessToken!], completion: {
            err, result in
            if ((err) != nil) {
                //TODO: handle
                return;
            }
            print(result)
            if let member = result!["room"]["members"].arrayObject {
                let rand = Int(arc4random_uniform(UInt32(member.count)))
                print(member)
                
            }
        })
        return []
    }
}