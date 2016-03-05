//
//  Chat.swift
//  barr
//
//  Created by Justin Hilliard on 2/26/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import SwiftyJSON

class Chat {
    let chateeId: String
    var messages:[Message] //each message contains the message string and the sender
    var containsUnread: Bool
    
    init(dict: JSON){
        self.containsUnread = false;
        self.messages = [];
        if let chateeId = dict["chateeId"].rawString(), messages = dict["messages"].rawValue as? [NSDictionary]{
            for msg: NSDictionary in messages {
                let msgString = msg["message"];
                let owner = msg["owner"];
                if (msgString != nil && owner != nil){
                    let newMsg = Message(message: msgString as! String, sender: owner as! String);
                    self.messages.append(newMsg);
                }
                else {
                    continue;
                }
            }
            self.chateeId = chateeId
        } else {
            self.messages = []
            self.chateeId = "Not Defined"
        }
    }
    
    func addMessage(message: String, sender: String){
        let newMessage = Message(message: message, sender: sender);
        messages.append(newMessage);
    }
}
