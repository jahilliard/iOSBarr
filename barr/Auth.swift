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
            (err, userAuth) -> Void in
            if ((err) != nil) {
                completion(err, false);
                return;
            }
            
            let userInfo = userAuth!["userInfo"];
            if userInfo != nil {
                if let fbId = userInfo["fbId"].rawString(), userId = userInfo["_id"].rawString(), firstName = userInfo["firstName"].rawString(), lastName = userInfo["lastName"].rawString(), email = userInfo["email"].rawString(), nickname = userInfo["nickname"].rawString(), isCreated = userAuth!["isCreated"].rawString()?.toBool(), accessToken = userAuth!["authToken"].rawString()
                {
                    Me.user.setVariables(fbAccessToken, fbId: fbId, accessToken: accessToken, userId: userId, firstName: firstName, lastName: lastName, nickname: nickname, email: email, pictures: userInfo["picture"].arrayValue.filter({ $0.string != nil }).map({ $0.string!}));
                    
                    completion(nil, isCreated);
                    /*self.wasUserCreated({err in
                        if ((err) != nil) {
                            completion(err, isCreated);
                        } else {
                            completion(nil, isCreated);
                        }}, isCreated: isCreated);*/
                    
                    return;
                }
            }
            
            print("There was a Login Error")
            completion(NSError(domain: "Response improperly formatted", code: 100, userInfo: nil), false);
        });
        }
    
    /*static private func wasUserCreated(completion: (NSError?) -> Void, isCreated: Bool){
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
    }*/
}
