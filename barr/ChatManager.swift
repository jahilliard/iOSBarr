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
    
    func addChatMessage(userId: String, message: String){
        if (self.chats[userId] == nil){
            self.chats[userId] = Chat(dict: ["chateeId": userId, "messages": []]);
        }
        
        var containsUnread = false;
        if (self.currentChateeId != userId && self.currentChateeId != Me.user.userId){
            containsUnread = true;
        }
        
        chats[userId]!.containsUnread = containsUnread;
        chats[userId]!.addMessage(message, sender: userId);
        
        //set the new order of chats
        if let index = self.chatOrder.indexOf(userId) {
            self.chatOrder.removeAtIndex(index);
        }
        
        self.chatOrder.insert(userId, atIndex: 0);
        print("NOTIFYING CHATS");
        notifyChats(userId);
    }
    
    func sendMessage(userId: String, message: String) {
        SocketManager.sharedInstance.sendMessage(userId, message: message, callback: {(err, data) in
            if (err != nil) {
                print(err);
                return;
            } else {
                self.addChatMessage(userId, message: message);
            }
        });
    }
}