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

let CircleUpdateNotification = "barr.com.app.CircleUpdateNotification";

class Circle {
    var locationId : String?;
    var circleId: String?;
    var members : [String: UserInfo] = [String: UserInfo]();
    var memberArray: [UserInfo] = [UserInfo]();
    
    static let sharedInstance : Circle = Circle();
    let userCellPhotoInfoCache : NSCache = NSCache();
    
    private init(){}
    
    func initCircle(dictionary: JSON) {
        self.memberArray = [UserInfo]();
        self.members = [String: UserInfo]();
        self.circleId = dictionary["circleId"].string;
        let members = dictionary["members"].arrayValue;
        
        for userInfo in members{
            self.addMember(userInfo);
            print(userInfo);
        }
        
        if members.count > 0 {
            self.notifyCircle();
        }
    }
    
    static func addMemberToCircleByLocation(lat: Double, lon: Double, completion: (res: JSON) -> Void){
        let subdomain = "api/v1/rooms/members/" + Me.user.userId!
        AlamoHelper.authorizedPost(subdomain, parameters: ["coordinate" : [lon, lat]], completion: {
            err, response in
            if (err != nil) {
                //TODO: handle
                return;
            } else {
                completion(res: response!)
            }
        })
    }
    
    func notifyCircle(){
        NSNotificationCenter.defaultCenter().postNotificationName(CircleUpdateNotification, object: self, userInfo: nil);
    }
    
    func addMember(userInfo: JSON) {
        if let singleMember = UserInfo(userInfo: userInfo) {
            var insertIndex = self.memberArray.count;
            if let userId = userInfo["_id"].string {
                if (self.members[userId] != nil) {
                    //find index of existing user in memberArray
                    insertIndex = self.memberArray.indexOf({$0.userId == userId})!;
                    self.memberArray.removeAtIndex(insertIndex);
                }
            } else {
                //TODO: error handling
                print("malformed userInfo from server");
                return;
            }
            
            self.members[singleMember.userId] = singleMember;
            self.memberArray.insert(singleMember, atIndex: insertIndex);
            notifyCircle();
        } else {
            //TODO: error handling
            print("malformed userInfo from server");
            return;
        }
    }
    
    func deleteMember(userId: String){
        if (self.members[userId] != nil) {
            //find index of existing user in memberArray
            let removeIndex = self.memberArray.indexOf({$0.userId == userId})!;
            self.memberArray.removeAtIndex(removeIndex);
            self.members.removeValueForKey(userId);
        }
        
        notifyCircle();
    }
    
    func sendOffer(to: String, offers: [UserInfo.OfferOptions]) {
        if let otherUser = self.members[to] {
            let intOffers = offers.map({UserInfo.convertToInt($0)!});
            var body = [String: AnyObject]();
            var fields = [String: AnyObject]();
            body["fields"] = fields;
            fields["offers"] = intOffers;
            AlamoHelper.authorizedPost("api/v1/matches/\(Me.user.userId!)/offers/\(to)", parameters: body, completion: {(err, resp) in
                if (err != nil) {
                    //TODO: alert user
                    self.sendOffer(to, offers: offers);
                    return;
                }
            })
            
            //update own offers
            otherUser.updateYourOffers(intOffers);
        }
    }
    
    func updateOffers(from: String, matchId: String, newOffers: [Int]){
        print(self.memberArray);
        if let member = self.members[from] {
            member.matchId = matchId;
            member.updateOtherOffers(newOffers);
        }
        
        //notify user now
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