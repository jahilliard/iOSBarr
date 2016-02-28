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
    
    static var currUser: User?
    
    static func sendAuthRequest(fbAccessToken: String, completeion: ((NSError?, Bool) -> Void)?){
        let params = ["access_token": fbAccessToken]
        AlamoHelper.GET("login/facebook", parameters: params, completion: {
            userAuth -> Void in
                currUser = User(fbAuthtoken: fbAccessToken, fbId: userAuth["fbId"].rawValue as! String, accessToken: userAuth["authToken"].rawValue as! String, userId: userAuth["id"].rawValue as! String)
                if let isCreated = userAuth["isCreated"].rawString()?.toBool() {
                    if (isCreated == true) {
                        print("User was Created")
                        populateNewUser(fbAccessToken, currUser: currUser!)
                    }
                    if let compBlock = completeion {
                        print("User NOT was Created")
                        compBlock(nil, isCreated)
                    }
                } else {
                    if let compBlock = completeion {
                        compBlock(NSError(domain: "isCreated not defined", code: 100, userInfo: nil), false)
                    }
                }
        })
    }
    
    static func populateNewUser(fbAuthtoken: String, currUser: User){
        print("Graph Call")
        currUser.makeFbGraphCall(["fields":"email,first_name,last_name,picture"], completion:
            {
                response in
                    updateUserInfo( response["first_name"].rawString()!, lastName: response["last_name"].rawString()!, email: response["email"].rawString()!)
            })
    }
    
    static func updateUserInfo(firstName: String, lastName: String, email: String){
        currUser?.updateUser(["lastName": lastName, "firstName": firstName, "email": email])
    }
}
