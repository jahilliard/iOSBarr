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
import CoreLocation

let CircleUpdateNotification = "barr.com.app.CircleUpdateNotification";
let CircleIdUpdateNofitification = "barr.com.app.CircleIdUpdateNotification";
class Circle {
    var circleId: String = "";
    var members : [String: UserInfo] = [String: UserInfo]();
    var memberArray: [UserInfo] = [UserInfo]();
    var coordinates : CLLocation! = nil;
    var radius: Double! = nil;
    
    static let sharedInstance : Circle = Circle();
    let userCellPhotoInfoCache : NSCache = NSCache();
    var lastJoinCircleRequest : requestTracker! = nil;
    
    private init(){}
    
    func resetCircle() {
        self.memberArray = [UserInfo]();
        self.members = [String: UserInfo]();
        self.circleId = "";
        self.coordinates = nil;
        self.radius = nil;
    NSNotificationCenter.defaultCenter().postNotificationName(CircleIdUpdateNofitification, object: self, userInfo: nil);
    }
    
    func initCircle(dictionary: JSON) -> Bool {
        self.resetCircle();
        if dictionary["circle"] == nil {
            //error return false
            return false;
        }
        
        if dictionary["circle"] == "" {
            //user not in a circle
            return false;
        }
        
        let circleInfo = dictionary["circle"];
        if let circleId = circleInfo["_id"].string, coordinates = circleInfo["geometry"]["coordinates"].array, radius = circleInfo["properties"]["radius"].double where coordinates.count >= 2 {
            if let lat = coordinates[1].double, lon = coordinates[0].double {
                self.circleId = circleId
                self.coordinates = CLLocation(latitude: lat, longitude: lon);
                self.radius = radius;
            } else {
                return false;
            }
            NSNotificationCenter.defaultCenter().postNotificationName(CircleIdUpdateNofitification, object: self, userInfo: nil);
        } else {
            return false;
        }
        
        let members = dictionary["members"].arrayValue;
        
        for userInfo in members{
            self.addMember(userInfo);
            print(userInfo);
        }
    
        self.notifyCircle();
        return true;
    }
    
    static func addMemberToCircleByLocation(lat: Double, lon: Double, callback: NSError? -> ()){
        if let lastJoinRequest = Circle.sharedInstance.lastJoinCircleRequest{
            if !lastJoinRequest.isFinished {
                lastJoinRequest.cancel();
            }
        }
        
        let subdomain = "api/v1/rooms/members/" + Me.user.userId!
        
        let reqTracker = AlamoHelper.authorizedPost(subdomain, parameters: ["coordinate" : [lon, lat]], completion: {
            err, response in
            if (err != nil) {
                callback(err)
                return;
            } else {
                if (response!["message"] != "success") {
                    //TODO: handle
                    callback(NSError(domain: "no success", code: 400, userInfo: nil));
                    return;
                } else {
                    if (Circle.sharedInstance.initCircle(response!["data"])) {
                        callback(nil);
                    } else {
                        //handle unsuccessful circle inititation
                        callback(NSError(domain: "malformed response", code: 400, userInfo: nil));
                    }
                }
            }
        });
        
        Circle.sharedInstance.lastJoinCircleRequest = reqTracker;
    }
    
    static func addMemberToCircleByID(roomId: String, completion: (err : NSError?, res: String?) -> Void){
        if roomId == "" {
            return;
        }
        
        let subdomain = "api/v1/rooms/" + roomId + "/members/" + Me.user.userId!
        AlamoHelper.authorizedPost(subdomain, parameters: [:], completion: {
            err, response in
            if (err != nil) {
                //TODO: handle
                completion(err: err, res: nil);
                return;
            } else {
                if (response!["message"] != "success") {
                    //TODO: handle
                    return;
                } else {
                    if (Circle.sharedInstance.initCircle(response!["data"])) {
                        completion(err: nil, res: response!["data"]["circle"]["_id"].string!);
                    } else {
                        //handle unsuccessful circle inititation
                    }
                }
            }
        })
    }
    
    static func deleteMemberFromCircleByID(roomId: String, completion: (err : NSError?, res: JSON?) -> Void){
        if roomId == Circle.sharedInstance.circleId {
            Circle.sharedInstance.resetCircle();
            Circle.sharedInstance.notifyCircle();
        }
        
        //even if roomId == "" or roomId != Circle.sharedInstance.circleId, still need 
        //to tell server to remove in case we got added but were never notified
        let subdomain = "api/v1/rooms/" + roomId + "/members/" + Me.user.userId!
        AlamoHelper.authorizedDelete(subdomain, parameters: [:], completion: {
            err, response in
            if (err != nil) {
                //TODO: handle
                completion(err: err, res: nil);
                return;
            } else {
                completion(err: nil, res: response!);
            }
        })
    }
    
    func notifyCircle(){
        NSNotificationCenter.defaultCenter().postNotificationName(CircleUpdateNotification, object: self, userInfo: nil);
    }
    
    func addMember(userInfo: JSON) {
        if (self.circleId == "") {
            return;
        }
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
        if (self.circleId == "") {
            return;
        }
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
        if (self.circleId == "") {
            return;
        }
        
        print(self.memberArray);
        if let member = self.members[from] {
            member.matchId = matchId;
            member.updateOtherOffers(newOffers);
        }
        
        //notify user now
    }
    
    func getCircleInfo(callback : String? -> Void){
        let subdomain = "api/v1/users/\(Me.user.userId!)/circle/";

        AlamoHelper.authorizedGet(subdomain, parameters: [String: AnyObject](), completion: {err, result in
            if (err != nil){
                //TODO: handle this better
                self.getCircleInfo(callback);
                return;
            }
                
            else if (result!["message"].string != "success") {
                self.getCircleInfo(callback);
                return;
            }
                
            else {
                if (result!["data"]["circleId"] == "") {
                    callback("");
                    return;
                }
                
                if (self.initCircle(result!["data"])) {
                    callback(result!["data"]["circleId"].string!);
                } else {
                    self.getCircleInfo(callback);
                }
            }
        });
    }
    
    static func getProfilePicture(userId: String, completion: UIImage -> Void) {
        if let userInfo = Circle.sharedInstance.members[userId] {
            //set photo
            if userInfo.pictures.count > 0 {
                let picURL = userInfo.pictures[0];
                if let img = Circle.sharedInstance.userCellPhotoInfoCache.objectForKey(picURL) as? UIImage{
                    completion(img)
                } else {
                    DownloadImage.downloadImage(NSURL(string: picURL)!) {
                        img in
                        Circle.sharedInstance.userCellPhotoInfoCache.setObject(img, forKey: picURL)
                        completion(img);
                    }
                }
            } else {
                //TODO: set default photo
                completion(UIImage(imageLiteral: "defaultProfilePicture.jpg"));
            }
        }
    }
    
    static func getProfilePictureByURL(picURL: String, completion: UIImage -> Void) {
        //set photo
        if let img = Circle.sharedInstance.userCellPhotoInfoCache.objectForKey(picURL) as? UIImage{
            completion(img)
        } else {
            DownloadImage.downloadImage(NSURL(string: picURL)!) {
                img in
                Circle.sharedInstance.userCellPhotoInfoCache.setObject(img, forKey: picURL)
                completion(img);
            }
        }
    }

    static func getPreview(locationId : String) -> [String]{
        var picArr: [String]
        AlamoHelper.GET("api/v1/rooms/locations/" + locationId, parameters: ["x_key": Me.user.userId!, "access_token": Me.user.accessToken!], completion: {
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