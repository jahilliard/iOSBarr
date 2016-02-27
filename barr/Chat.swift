//
//  Chat.swift
//  barr
//
//  Created by Justin Hilliard on 2/26/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import SwiftyJSON

class Chat {
    var chateeId: String
    var messages:[String]
    
    
    init(dict: JSON){
        if let chateeId = dict["chateeId"].rawString(), messages = dict["messages"].rawValue as? [String]{
            self.messages = messages
            self.chateeId = chateeId
        } else {
            self.messages = []
            self.chateeId = "Not Defined"
        }
    }
}
