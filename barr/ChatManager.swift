//
//  ChatManager.swift
//  barr
//
//  Created by Carl Lin on 2/28/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import Foundation
import SwiftyJSON

class ChatManager {
    static let sharedInstance : ChatManager = ChatManager();
    var chats = [String: Chat]();
    var currentChateeId : String?;
    let newMessageNotification = "com.barr.messageNotification";
    let chatListNotification = "com.barr.chatListNotification";
    
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
    
    func notifyChats(userId: String, count: Int) {
        NSNotificationCenter.defaultCenter().postNotificationName(self.newMessageNotification, object: self, userInfo: ["chateeId": userId, "count": count]);
    }
    
    func notifyChatList() {
        NSNotificationCenter.defaultCenter().postNotificationName(self.chatListNotification, object: self, userInfo: nil);
    }
    
    func getLatestChats(){
        let subdomain = "api/v1/chats/search";
        AlamoHelper.authorizedGet(subdomain, parameters: [String: AnyObject](), completion: {result in self.processChats(result)});
    }
    
    func processChats(chatDicts: JSON) {
        let chatArray = chatDicts["chats"].arrayValue;
        
        if (chatArray.count == 0){
            return;
        }
        
        print(chatDicts);
        for chatDict in chatArray {
            if let chatee = chatDict["chatee"].string,
                dateString = chatDict["date"].string,
                date = Helper.dateFromString(dateString)
            {
                let newChat = Chat(dict: ["chateeId": chatee, "messages": []]);
                
                if let lastMsgNum = chatDict["lastMsgNum"].int {
                    newChat.lastMessageNum = lastMsgNum;
                } else {
                    newChat.lastMessageNum = 0;
                }
                
                let message = chatDict["latestMsg"].string;
                
                if (message != nil) {
                    print("MESSAGE PREVIEW");
                    newChat.preview = message!;
                }
                
                newChat.containsUnread = (message != nil);
                newChat.lastUpdate = date;
                self.chats[chatee] = newChat;
                print("ADDED NEW CHAT");
                print(self.chats);
            }
        }
        
        notifyChatList();
    }
    
    //process actual requested messages after a user opens a particular chat
    //by clicking on that chat from the chatList
    func processOpenedMessages(chateeId: String, chatMessages: [JSON]){
        print("PROCESSING OPENED");
        if (self.currentChateeId != chateeId){
            return;
        }
        
        if (self.chats[chateeId] == nil){
            print("CHAT SHOULD NOT BE NIL AFTER GETTING OPENED MESSAGES");
            return;
        }
        
        var newMessages = [Message]();
        var messageIds = [String]();
        let chat = self.chats[chateeId]!;
        
        print(chatMessages);
        for messageDict in chatMessages {
            if let message = messageDict["message"].string,
                dateString = messageDict["date"].string,
                date = Helper.dateFromString(dateString)
            {
                let newMsg = Message(message: message, sender: chateeId, date: date, status: Message.MessageStatus.CHATEEMESSAGE, messageNum: nil);
                newMessages.append(newMsg);
            }
            
            if let id = messageDict["_id"].string{
                messageIds.append(id);
            }
        }
    
        if (newMessages.count > 0) {
            //tell server you have gotten these messages
            //TODO: WHAT HAPPENS IF THIS FAILS (do something with completion block?)
            let subdomain = "api/v1/chats/\(Me.user.userId!)/messages/\(chateeId)/isRead";
            AlamoHelper.authorizedPost(subdomain, parameters: ["messageIds": messageIds], completion: nil);
            chat.appendMessages(newMessages);
            notifyChats(chateeId, count: newMessages.count);
        }
    }
    
    func retrieveUnread(chateeId: String) {
        print("retrieving");
        let subdomain = "api/v1/chats/\(Me.user.userId!)/messages/\(chateeId)";
        AlamoHelper.authorizedGet(subdomain, parameters: [String: AnyObject](), completion: {result in self.processOpenedMessages(chateeId, chatMessages: result["chatMessages"].arrayValue)});
    }
    
    //process a NOTIFICATION of a new message. Only save the message if it is the current active chat (i.e. the user opened it). Also updates the chatList order and preview
    func processNewMessage(newMessage: NSDictionary){
        if let chateeId = newMessage["from"] as? String, messageText = newMessage["message"] as? String,
            dateString = newMessage["date"] as? String,
            date = Helper.dateFromString(dateString)
        {
            if (self.chats[chateeId] == nil){
                self.chats[chateeId] = Chat(dict: ["chateeId": chateeId, "messages": []]);
            }
            
            let chateeChat = self.chats[chateeId]!
            
            //change the preview in the chatlist
            chateeChat.preview = messageText;
            
            //flag unread if not the current chat
            var containsUnread = false;
            if (self.currentChateeId != chateeId &&
                self.currentChateeId != Me.user.userId)
            {
                containsUnread = true;
            }
            
            chateeChat.containsUnread = containsUnread;
            
            chateeChat.lastUpdate = date;
            
            //if is current active chat
            if self.currentChateeId == chateeId {
                self.retrieveUnread(chateeId);
            }
            
            print("NOTIFYING CHAT LIST");
            self.notifyChatList();
        }
    }
    
    func openChat(chateeId: String){
        if (self.chats[chateeId] == nil){
            self.chats[chateeId] = Chat(dict: ["chateeId": chateeId, "messages": []]);
        } else {
            self.retrieveUnread(chateeId);
        }
    
        self.currentChateeId = chateeId;
    }

    func closeChat() {
        if (self.currentChateeId == nil) {
            return;
        }
        
        //destroy all messages in chat
        if let chat = self.getChat(self.currentChateeId!){
            chat.close();
        } else {
            print("ERROR CHAT SHOULD EXIST IN ORDER TO CLOSE");
        }
        
        //reset current chat
        self.currentChateeId = nil;
    }
    
    func socketSendMessage(chateeId: String, message: String, messageNumber: Int,callback: (NSError?, NSDictionary?) -> ())
    {
        SocketManager.sharedInstance.sendMessage(chateeId, message: message, messageNumber: messageNumber, callback: {(err, data) in
            if (err != nil) {
                callback(err, nil);
                return;
            } else {
                callback(nil, data);
            }
        });
    }
    
    //TODO: what if callback is called after view is destroyed
    func sendMessage(chateeId: String, message: Message, callback: (NSError?, NSDictionary?) -> ()) {
        //add message to the chat it belongs to, date is current system date, will 
        //be updated to server date when response from server comes back
        
        self.socketSendMessage(chateeId, message: message.message, messageNumber: message.messageNum!, callback: callback);
        
    }
}