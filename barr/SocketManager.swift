//
//  SocketManager.swift
//  barr
//
//  Created by Carl Lin on 2/27/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import Foundation
import SwiftyJSON
import SocketIOClientSwift

class SocketManager {
    var socket : SocketIOClient?;
    
    static let sharedInstance : SocketManager = SocketManager();

    /*func registerHandler(eventName: String, handler: NSArray -> ()){
        socket.on(eventName, callback: {(data, ack) in handler(data) });
    }*/
    
    private init(){};
    
    
    func sendMessage(userId: String, message: String, messageNumber: Int, callback : (NSError?, NSDictionary?) -> ()) {
        if self.socket == nil {
            let error = NSError(domain: "No Connection to Server", code: 400, userInfo: nil);
            callback(error, nil);
            return;
        }
        
        let ack = socket!.emitWithAck("ChatMessage", ["receiver": userId, "message": message, "messageNumber": messageNumber]);
        ack(timeoutAfter: 10, callback: {(statusArray) in
            print(statusArray);
            if (statusArray.count == 2) {
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
            }
            
            else if (statusArray.count == 1){
                if let msg = statusArray[0] as? String {
                    if msg == "NO ACK" {
                        let error = NSError(domain: "Connection Error", code: 400, userInfo: nil);
                        callback(error, nil);
                        return;
                    }
                }
                
                let error = NSError(domain: "Unknown Error", code: 400, userInfo: nil);
                callback(error, nil);
            }
            
            else {
                let error = NSError(domain: "Unknown Error", code: 400, userInfo: nil);
                callback(error, nil);
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
    
    func open(){
        //create new socket
        let connectParams = ["id": Me.user.userId!, "access_token": Me.user.accessToken!];
        
        self.socket = SocketIOClient(socketURL: NSURL(string: "http://10.0.0.2:3000")!, options: ["connectParams" : connectParams]);
        
        /*self.socket = SocketIOClient(socketURL: NSURL(string: "http://172.31.98.21:3000")!, options: ["connectParams" : connectParams]);*/

        print("SOCKET MANAGER INITING");
        
        self.socket!.on("newMessage", callback: {(data, ack) in
            print("NEW MESSAGE");
            print(data);
            if (data.count <= 0){
                return;
            }
            
            if let response = data[0] as? NSDictionary, newMessage = response["message"] as? NSDictionary{
                ChatManager.sharedInstance.processNewMessage(newMessage);
            }
            /*ChatManager.sharedInstance.addChatMessage(sender, ownerId: sender, message: messageText);*/
        });
        
        /*self.socket!.on("newFeedPosts", callback: {(data, ack) in self.FeedManager.});*/

        self.socket!.on("newCircleMember", callback: {(data, ack) in print("NEW CIRCLE MEMBER")});
        
        self.socket!.on("connect", callback: {(data, ack) in
            //retrieve latest chats
            ChatManager.sharedInstance.getLatestChats();
            //update location, join nearest circle
            LocationTracker.tracker.getCircleInfoOnReconnect();
            print("socket connected");
            //display map view controller
        });
        
        self.socket!.on("newCircleMember", callback: {(data, ack) in
            if (data.count <= 0){
                return;
            }
            
            if let data = data[0] as? NSDictionary, newMember = data["newMember"] as? NSDictionary
            {
                Circle.sharedInstance.addMember(JSON(newMember));
            }
        });
            
        self.socket!.on("circleMemberLeave", callback: {(data, ack) in
            print(data);
            if (data.count <= 0){
                return;
            }
            
            if let data = data[0] as? NSDictionary, oldMember = data["oldMember"] as? NSDictionary, userId = oldMember["_id"] as? String {
                Circle.sharedInstance.deleteMember(userId);
            }
        });
        
        self.socket!.on("newOffers", callback: {(data, ack) in
            if (data.count <= 0){
                return;
            }
            
            print(data[0]);
            if let data = data[0] as? NSDictionary, from = data["from"] as? String, matchId = data["matchId"] as? String, newOffers = data["newOffers"] as? [Int] {
                Circle.sharedInstance.updateOffers(from, matchId: matchId, newOffers: newOffers);
            }
        });
        
        self.socket!.on("disconnect", callback: {(data, ack) in
            //handle disconnect
        });
        
        self.socket!.on("reconnect", callback: {(data, ack) in
            //handle reconnect
            print("RECONNECTING");
        });
        
        self.socket!.on("reconnectAttempt", callback: {(data, ack) in
            //handle reconnect
            print("RECONNECT ATTEMPT");
        });
        
        self.socket!.on("error", callback: {(data) in
            print(data);
        });

        print("SOCKET CONNECTING");
        self.socket!.connect();
    }
    
    func close(){
        if let socket = self.socket {
            socket.disconnect();
            self.socket = nil;
        }
    }
}
