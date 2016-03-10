//
//  Message.swift
//  barr
//
//  Created by Carl Lin on 2/28/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import Foundation

struct Message{
    var message: String
    var sender: String
    init(message: String, sender: String)
    {
        self.message = message
        self.sender = sender
    }
}