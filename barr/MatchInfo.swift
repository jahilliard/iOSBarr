//
//  MatchInfo.swift
//  barr
//
//  Created by Justin Hilliard on 2/21/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import Foundation

class MatchInfo {
    let userInfo: UserInfo;
    let isOpen: Bool;
    let expire: NSDate;
    
    init(userInfo: UserInfo, isOpen: Bool, expire: NSDate){
        self.userInfo = userInfo;
        self.isOpen = isOpen;
        self.expire = expire;
    }
}