//
//  Match.swift
//  barr
//
//  Created by Justin Hilliard on 2/10/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

//import Foundation
//import Alamofire
//import SwiftyJSON
//
//class Match  {
//    let userId: String;
//    var matchList: [String: MatchInfo];
//    
//    init(userId: String, matchList: [NSDictionary]?){
//        self.userId = userId;
//        self.matchList = [String: MatchInfo]();
//        if let matchListIter = matchList{
//            for match in matchListIter {
//                let matchJSON = JSON(match)
//                let singleMatch = MatchInfo(userInfo: UserInfo(userInfo: matchJSON["userInfo"]), isOpen: matchJSON["isOpen"].rawValue as! Bool, expire: matchJSON["expire"].rawValue as! NSDate);
//                self.matchList[singleMatch.userInfo.userId] = singleMatch;
//            }
//        }
//    }
//    
//    func addMatch(match: NSDictionary){
//        let matchJSON = JSON(match)
//        let singleMatch = MatchInfo(userInfo: UserInfo(userInfo: matchJSON["userInfo"]), isOpen: matchJSON["isOpen"] as! Bool, expire: matchJSON["expire"] as! NSDate);
//        self.matchList[singleMatch.userInfo.userId] = singleMatch;
//    }
//    
//    func deleteMatch(userId: String){
//        self.matchList.removeValueForKey(userId);
//    }
//    
//}