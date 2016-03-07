//
//  SocketManager.swift
//  barr
//
//  Created by Carl Lin on 2/27/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import Foundation
import SocketIOClientSwift

class SocketManager {
    let socket : SocketIOClient;
    
    static let sharedInstance : SocketManager = SocketManager();

    /*func registerHandler(eventName: String, handler: NSArray -> ()){
        socket.on(eventName, callback: {(data, ack) in handler(data) });
    }*/
    
    private init(){
        let connectParams = ["id": Me.user.userId!, "access_token": Me.user.accessToken!];
        self.socket = SocketIOClient(socketURL: NSURL(string: "http://192.168.1.9:3000")!, options: ["connectParams" : connectParams]);
        print("SOCKET MANAGER INITING");
        
        self.socket.on("newMessage", callback: {(data, ack) in
            print("NEW MESSAGE");
            if (data.count <= 0){
                return;
            }
            
            let newMessage = data[0];
            
            if let sender = newMessage["from"] as? String,
                messageText = newMessage["message"] as? String
            {
                ChatManager.sharedInstance.addChatMessage(sender, message: messageText);
            }
            
            /*let sender = data["from"];
            let message = data["message"];
            let chat = chats[sender];
            chat.addMessage(message, sender)*/
        });
        
        self.socket.on("connect", callback: {(data, ack) in
            print("socket connected");
        });
        
        self.socket.connect();
    }
    
    func sendMessage(userId: String, message: String, callback : (NSError?, NSDictionary?) -> ()) {
        let ack = socket.emitWithAck("ChatMessage", ["receiver": userId, "message": message]);
        
        ack(timeoutAfter: 5, callback: {(statusArray) in
            let statusDict = statusArray[1] as? NSDictionary;
            let statusMessage = statusArray[0] as? String;
            if (statusMessage == nil || statusMessage! != "success"){
                if(statusDict != nil){
                    let error = NSError(domain: "Send Message Error", code: 400, userInfo: statusDict! as [NSObject : AnyObject]);
                    callback(error, nil);
                } else {
                    let error = NSError(domain: "Send Message Error", code: 400, userInfo: nil);
                    callback(error, nil);
                }
            } else {
                callback(nil, statusDict);
            }
        })
    }
    /*func sendMessage(userId: String, message: String, callback : (NSError?, NSDictionary) -> ()){
        self.socket.emitWithAck("ChatMessage", ["receiver": userId, "message": message]){
            (err, data) in
            print("IN CALLBACK");
            if (err != nil) {
                callback(NSError(err), data);
                return;
            } else {
                callback(nil, data);
            }
        };
    }*/
    
    func initialize(){}
}
