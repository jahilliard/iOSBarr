//
//  Auth.swift
//  barr
//
//  Created by Justin Hilliard on 2/19/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import FBSDKCoreKit
import FBSDKLoginKit
import SwiftyJSON

struct Auth {
    
    static private var completion:  ((NSError?, Bool) -> Void)?
    static private var wasCreated: Bool?
    
    static func sendAuthRequest(fbAccessToken: String, completion: ((NSError?, Bool) -> Void)?){
        /*OLDCODE >>>> let params = ["access_token": fbAccessToken]
        AlamoHelper.GET("login/facebook", parameters: params, completion: {
            userAuth -> Void in
            if let fbId = userAuth["fbId"].rawString(), accessToken = userAuth["authToken"].rawString(), userId = userAuth["id"].rawString(), isCreated = userAuth["isCreated"].rawString()?.toBool()
            {
                self.wasCreated = isCreated
                self.completion = completion
                Me.user.setVariables(fbAccessToken, fbId: fbId, accessToken: accessToken, userId: userId)
                
                print("STARTING SOCKETS");
                SocketManager.sharedInstance.open();
                self.wasUserCreated()
            }
        })>>>OLD CODE*/
        
        Me.user.setVariables("", fbId: "", accessToken: "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjoiNTZlNjE5MzMwNDZlOTU3MWNmNWM5OGFhIiwiZXhwIjoxNDU4NTI1MzQwODEwfQ.4ixHj2YZy4bEqHXOX7NBVg2EVn_hB5nsKFTDj2hQWhA", userId: "56e61933046e9571cf5c98aa");
        
        print("STARTING SOCKETS");
        SocketManager.sharedInstance.open();
        
        //retrieve latest chats
        ChatManager.sharedInstance.getLatestChats();
    }
    
    static private func wasUserCreated(){
        print(wasCreated)
        if let isCreated = wasCreated {
            if (isCreated == true) {
                print("User was Created")
                Me.user.createUser()
            } else {
                if let compBlock = completion {
                    print("User NOT was Created")
                    compBlock(nil, isCreated)
                }
            }
        } else {
            if let compBlock = completion {
                print("There was a Login Error")
                compBlock(NSError(domain: "isCreated not defined", code: 100, userInfo: nil), false)
            }
        }
    }
    
    
//    static func populateNewUser(fbAuthtoken: String){
//        print("Graph Call")
//        currUser.makeFbGraphCall(["fields":"email,first_name,last_name,picture"], completion:
//            {
//                response in
//                    updateUserInfo(currUser, firstName: response["first_name"].rawString()!, lastName: response["last_name"].rawString()!, email: response["email"].rawString()!, picture: response["print"].rawString()!)
//            })
//    }
//    
//    static func updateUserInfo(currUser: User, firstName: String, lastName: String, email: String, picture: String){
//        print(picture)
//        currUser.updateUser(["lastName": lastName, "firstName": firstName, "email": email])
//    }
}
