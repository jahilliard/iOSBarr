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
    enum OfferOptions {
        case HEART
        case DRINK
    }
    
    let userId : String;
    let nickname : String;
    let firstName: String;
    let lastName: String;
    let picture: String;
    var yourOffers: [OfferOptions]
    var otherOffers: [OfferOptions]
    var matchId: String?;
    
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
        if let userId = userInfo["_id"].rawString(){
            self.userId = userId
        } else {
            self.userId = ""
        }
        if let nickname = userInfo["nickname"].rawString(){
            self.nickname = nickname;
        } else {
            self.nickname = "nickname";
        }
        
        if let firstName = userInfo["firstName"].rawString(){
            self.firstName = firstName;
        } else {
            self.firstName = "firstName";
        }
        
        if let lastName = userInfo["lastName"].rawString(){
            self.lastName = lastName;
        } else {
            self.lastName = "lastName";
        }
        
        if let picture = userInfo["picture"].rawString() {
            self.picture = picture;
        } else {
            self.picture = "picture";
        }

        self.yourOffers = [];
        self.otherOffers = [];
        self.matchId = nil;
        
        if userInfo["matches"] != nil{
            let matchInfo = userInfo["matches"];
            let yourOffers = matchInfo["yourOffers"];
            let otherOffers = matchInfo["otherOffers"];
            let matchId = matchInfo["matchId"].string;
            
            if yourOffers != nil{
                self.yourOffers = parseOffers(yourOffers.arrayValue);
            }
            
            if otherOffers != nil{
                self.otherOffers = parseOffers(otherOffers.arrayValue);
            }
            
            if matchId != nil {
                self.matchId = matchId;
            }
        }
    }
    
    func parseOffers(offers: [JSON]) -> [OfferOptions] {
        var result : [OfferOptions] = [];
        for offer in offers {
            if offer.int == 0 {
                result.append(OfferOptions.HEART);
            }
            
            else if offer.int == 1 {
                result.append(OfferOptions.DRINK);
            }
        }
        return result;
    }
}
