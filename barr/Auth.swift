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
    
    static func sendAuthRequest(fbAccessToken: String){
            let params = ["access_token": fbAccessToken]
            AlamoHelper.GET("login/facebook", parameters: params, completion: {
                userAuth -> AnyObject in
                    currUser = User(fbAuthtoken: fbAccessToken, fbId: userAuth["fbId"].rawValue as! String, accessToken: userAuth["authToken"].rawValue as! String, userId: userAuth["id"].rawValue as! String)
//                  print("\(userAuth["isCreated"].rawValue as! Bool)")
//                  let isCreated = userAuth["isCreated"].rawValue as! Bool
                    let isCreated = true
                    if (isCreated == true) {
                        populateNewUser(fbAccessToken, currUser: currUser!)
                    }
                    return true
            })
//        }
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
