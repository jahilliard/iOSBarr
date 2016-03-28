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
        case POKE
    }
    
    let userId : String;
    let nickname : String;
    let firstName: String;
    let lastName: String;
    let pictures: [String];
    var yourOffers: [OfferOptions : Bool];
    var otherOffers: [OfferOptions : Bool];
    var matchId: String?;
    
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
        
        let pictures = userInfo["picture"].arrayValue;
        self.pictures = pictures.filter({ $0.string != nil }).map({ $0.string!});
        print(pictures);

        self.yourOffers = [OfferOptions : Bool]();
        self.otherOffers = [OfferOptions : Bool]();
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
    
    static func convertToOption(offer: Int) -> OfferOptions? {
        if offer == 0 {
            return OfferOptions.HEART;
        }
            
        else if offer == 1 {
            return OfferOptions.POKE;
        }
        
        else {
            return nil;
        }
    }
    
    static func convertToInt(option: OfferOptions) -> Int? {
        if option == OfferOptions.HEART {
            return 0;
        }
        
        else if option == OfferOptions.POKE {
            return 1;
        }
        
        else {
            return nil;
        }
    }
    
    func updateOtherOffers(offers: [Int]) {
        print(self.otherOffers);
        for offer in offers {
            if let offerOption = UserInfo.convertToOption(offer){
                self.otherOffers[offerOption] = true;
            }
        }
    }
    
    func updateYourOffers(offers: [Int]) {
        for offer in offers {
            if let offerOption = UserInfo.convertToOption(offer){
                self.yourOffers[offerOption] = true;
            }
        }
    }
    
    func parseOffers(offers: [JSON]) -> [OfferOptions : Bool] {
        var result : [OfferOptions : Bool] = [OfferOptions : Bool]();
        for offer in offers {
            if let offerInt = offer.int {
                if let offerOption = UserInfo.convertToOption(offerInt){
                    result[offerOption] = true;
                }
            }
        }
        return result;
    }
}
