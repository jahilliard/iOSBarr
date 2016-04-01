//
//  Chat.swift
//  barr
//
//  Created by Justin Hilliard on 2/26/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import SwiftyJSON

class Chat {
    var chatee: UserInfo;
    var messages:[Message] //each message contains the message string and the sender
    var messageNumToMessage: [Int: Message]
    var containsUnread: Bool
    var preview: String?
    var lastMessageNum : Int; //TODO: Set this when when chatee is added to circle
    var numTimesClosed = 0;
    
    var lastUpdate: NSDate = NSDate.distantPast()
    
    init(chatee: UserInfo, messages : [NSDictionary]){
        self.preview = nil;
        self.containsUnread = false;
        self.messages = [];
        self.messageNumToMessage = [Int: Message]();
        self.chatee = chatee;
        self.lastMessageNum = chatee.lastMsgNum;
        
        for msg: NSDictionary in messages {
            if let msgString = msg["message"] as? String, owner = msg["owner"] as? String, status = msg["status"] as? Message.MessageStatus, messageNum = msg["messageNum"] as? Int, dateString = msg["date"] as? String, date = Helper.dateFromString(dateString)
            {
                let newMsg = Message(message: msgString, sender: owner, date: date, status: status, messageNum: messageNum);
                self.messages.append(newMsg);
            }
            else {
                continue;
            }
        }
    }
    
    func close() {
        self.preview = nil;
        self.messages = [];
        self.messageNumToMessage = [Int: Message]();
        self.numTimesClosed++;
    }
    
    func getMsgByMsgNumber(msgNumber: Int) -> Message? {
        return self.messageNumToMessage[msgNumber];
    }
    
    func setMsgByMsgNumber(msgNumber: Int, msg: Message) {
        self.messageNumToMessage[msgNumber] = msg;
    }
    
    func addMyMessage(message: String, date: NSDate, status: Message.MessageStatus) -> Message{
        self.lastMessageNum++;
        let newMessage = Message(message: message, sender: Me.user.userId!, date: date, status: status, messageNum: self.lastMessageNum);
        self.messageNumToMessage[self.lastMessageNum] = newMessage;
        messages.append(newMessage);
        self.lastUpdate = date;
        return newMessage;
    }
    
    func appendMessages(newMessages: [Message]){
        self.messages += newMessages;
        if (newMessages.count > 0) {
            self.lastUpdate = newMessages[newMessages.count - 1].date;
        }
    }
    
    func changeLastUpdate(date: NSDate){
        if (date.timeIntervalSince1970 > self.lastUpdate.timeIntervalSince1970){
            self.lastUpdate = date;
        }
    }
}
