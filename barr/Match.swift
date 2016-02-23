//
//  Match.swift
//  barr
//
//  Created by Justin Hilliard on 2/10/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class Match  {
    let userId: String;
    var matchList: [String: MatchInfo];
    
    init(userId: String, matchList: [NSDictionary]?){
        self.userId = userId;
        self.matchList = [String: MatchInfo]();
        if let matchListIter = matchList{
            for match in matchListIter {
//                var matchJSON = JSON(match)
                let singleMatch = MatchInfo(userInfo: UserInfo(userId: match["userInfo"]!["userId"] as! String, nickname: match["userInfo"]!["nickname"] as! String, firstName: match["userInfo"]!["firstName"] as! String, lastName: match["userInfo"]!["lastName"] as! String, img: match["userInfo"]!["img"] as! String), isOpen: match["isOpen"] as! Bool, expire: match["expire"] as! NSDate);
                self.matchList[singleMatch.userInfo.userId] = singleMatch;
            }
        }
    }
    
    func addMatch(match: NSDictionary){
        let singleMatch = MatchInfo(userInfo: UserInfo(userId: match["userInfo"]!["userId"] as! String, nickname: match["userInfo"]!["nickname"] as! String, firstName: match["userInfo"]!["firstName"] as! String, lastName: match["userInfo"]!["lastName"] as! String, img: match["userInfo"]!["img"] as! String), isOpen: match["isOpen"] as! Bool, expire: match["expire"] as! NSDate);
        self.matchList[singleMatch.userInfo.userId] = singleMatch;
    }
    
    func deleteMatch(userId: String){
        self.matchList.removeValueForKey(userId);
    }
    
}