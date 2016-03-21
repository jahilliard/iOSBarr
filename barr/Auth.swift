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
    static let MAX_CREATE_ATTEMPTS : UInt64 = 10;
    
    static func sendAuthRequest(fbAccessToken: String, completion: (NSError?, Bool) -> Void){
        let params = ["access_token": fbAccessToken]
        AlamoHelper.GET("login/facebook", parameters: params, completion: {
            userAuth -> Void in
                if let fbId = userAuth["fbId"].rawString(), accessToken = userAuth["authToken"].rawString(), userId = userAuth["id"].rawString(), isCreated = userAuth["isCreated"].rawString()?.toBool()
                {
                    Me.user.setVariables(fbAccessToken, fbId: fbId, accessToken: accessToken, userId: userId)
                
                    self.wasUserCreated({err in
                        if ((err) != nil) {
                            completion(err, isCreated);
                        } else {
                            completion(nil, isCreated);
                        }}, isCreated: isCreated);
                } else {
                    print("There was a Login Error")
                    completion(NSError(domain: "Response improperly formatted", code: 100, userInfo: nil), false);
                }
        });
        }
    
    static private func wasUserCreated(completion: (NSError?) -> Void, isCreated: Bool){
        if isCreated {
            print("User was Created")
            var createAttempts : UInt64 = 0;
            func callback(err : NSError?) -> Void {
                if (err != nil) {
                    //reached maximum attempts
                    if (createAttempts == MAX_CREATE_ATTEMPTS) {
                        completion(err);
                    } else {
                        //try updating user again
                        createAttempts += 1;
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * createAttempts * NSEC_PER_SEC)), dispatch_get_main_queue()) {
                            Me.user.createUser(callback: callback);
                        }
                    }
                } else {
                    completion(nil);
                }
            }
        
            Me.user.createUser(callback: callback);
        } else {
            completion(nil);
        }
    }
}
