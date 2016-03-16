//
//  Message.swift
//  barr
//
//  Created by Carl Lin on 2/28/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import Foundation

class Message{
    enum MessageStatus {
        case PENDING
        case RECEIVED
        case FAILED //failed to send
        case CHATEEMESSAGE
    }
    
    var message: String
    var sender: String
    var date: NSDate
    var status: MessageStatus
    var messageNum: Int?
    
    init(message: String, sender: String, date: NSDate, status: MessageStatus, messageNum: Int?)
    {
        self.message = message;
        self.sender = sender;
        self.date = date;
        self.status = status;
        self.messageNum = messageNum;
    }
}