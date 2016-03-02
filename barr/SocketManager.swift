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
    
    static let sharedInstance = SocketManager();

    /*func registerHandler(eventName: String, handler: NSArray -> ()){
        socket.on(eventName, callback: {(data, ack) in handler(data) });
    }*/
    
    private init(){
        self.socket = SocketIOClient(socketURL: NSURL(string: "http://10.0.0.3:3000")!, options: ["connectParams" : ["id": "56d35862ca9a1dbd590d8b5c", "access_token" : "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjoiNTZkMzU4NjJjYTlhMWRiZDU5MGQ4YjVjIiwiZXhwIjoxNDU3Mjk3MTA1NTAzfQ.t77dtS76-dPzz2pMQJcS-9mGRnqlUQyKTcw5OdOkpwA"]]);
        print("SOCKET MANAGER INITING");
        
        self.socket.on("newMessage", callback: {(data, ack) in
            print(data);
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
    
    func initialize(){}
}
