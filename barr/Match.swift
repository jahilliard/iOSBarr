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
    let matchList: [String: MatchInfo];
    
    init(userId: String, matchList: [NSDictionary]?){
        self.userId = userId;
        self.matchList = [String: matchList]();
        if(matchList != nil){
            for match in matchList {
                let singleMatch = MatchInfo(UserInfo(match["userInfo"], match["isOpen"], match["expire"]));
                self.matchList[singleMatch.userInfo.userId] = singleMatch;
            }
        }
    }
    
    func addMatch(match: [NSDictionary]){
        let singleMatch = MatchInfo(UserInfo(match["userInfo"], match["isOpen"], match["expire"]));
        self.matchList[singleMatch.userInfo.userId] = singleMatch;
    }
    
    func deleteMatch(userId: String){
        self.matchList.removeValueForKey(userId);
    }
    
}