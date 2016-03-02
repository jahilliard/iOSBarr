//
//  ChatManager.swift
//  barr
//
//  Created by Carl Lin on 2/28/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import Foundation

class ChatManager {
    static let sharedInstance = ChatManager();
    private let chats = [String: Chat]();
    
    private init(){
        /*SocketManager.sharedInstance.registerHandler("newMessage", handler: {(data) in
            print(data);
            /*let sender = data["from"];
            let message = data["message"];
            let chat = chats[sender];
            chat.addMessage(message, sender)*/
        });*/
    }
    
    func getChat(userId: String) -> Chat? {
        return chats[userId];
    }
}