//
//  FeedEntry.swift
//  barr
//
//  Created by Carl Lin on 4/2/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import Foundation

import Foundation
import Alamofire
import SwiftyJSON

class FeedEntry {
    enum FeedEntryEnum: Int {
        case TEXT;
        case IMAGE;
        case VIDEO
    }
    
    let authorInfo: UserInfo
    let entryId: String;
    let type: FeedEntryEnum;
    let text: String;
    var mainImage: UIImage? = nil;
    let date: NSDate;
    var imageHeight : CGFloat = 0;
    
    init(authorInfo: UserInfo, entryId: String, type: FeedEntryEnum, text: String, date: NSDate){
        self.authorInfo = authorInfo;
        self.entryId = entryId;
        self.type = type;
        self.text = text;
        self.date = date;
    }
}
