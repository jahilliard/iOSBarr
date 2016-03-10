//
//  ChatManager.swift
//  barr
//
//  Created by Carl Lin on 2/28/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import Foundation

class ChatManager {
    static let sharedInstance : ChatManager = ChatManager();
    var chats = [String: Chat]();
    var chatOrder : [String] = [];
    var currentChateeId : String?;
    let newMessageNotification = "com.barr.messageNotification";
    
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
        return self.chats[userId];
    }
    
    func notifyChats(userId: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(self.newMessageNotification, object: self, userInfo: ["chateeId": userId]);
    }
    
    func addChatMessage(chateeId: String, ownerId: String, message: String){
        if (self.chats[chateeId] == nil){
            self.chats[chateeId] = Chat(dict: ["chateeId": chateeId, "messages": []]);
        }
        
        var containsUnread = false;
        if (self.currentChateeId != chateeId &&
            self.currentChateeId != Me.user.userId)
        {
            containsUnread = true;
        }
        
        chats[chateeId]!.containsUnread = containsUnread;
        chats[chateeId]!.addMessage(message, sender: ownerId);
        
        //set the new order of chats
        if let index = self.chatOrder.indexOf(chateeId) {
            self.chatOrder.removeAtIndex(index);
        }
        
        self.chatOrder.insert(chateeId, atIndex: 0);
        print("NOTIFYING CHATS");
        notifyChats(chateeId);
    }
    
    func sendMessage(chateeId: String, message: String, callback: (NSError?, NSDictionary?) -> ()) {
        SocketManager.sharedInstance.sendMessage(chateeId, message: message, callback: {(err, data) in
            if (err != nil) {
                callback(err, nil);
                return;
            } else {
                self.addChatMessage(chateeId, ownerId: Me.user.userId!, message: message);
                callback(nil, data);
            }
        });
    }
}