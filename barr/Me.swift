//
//  Me.swift
//  barr
//
//  Created by Justin Hilliard on 2/27/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import SwiftyJSON
import FBSDKCoreKit

class Me {
    static let user: Me = Me()
    
    var fbId: String?
    var firstName: String?
    var lastName: String?
    var nickname: String?
    var fbAuthtoken: String?
    var userId: String?
    var accessToken: String?
    var email: String?
    
    var newestValidateInfo = false
    
    var currentCircleId: String?
    var picturesArr: [String]?
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    private init() {}
    
    func setVariables(fbAuthtoken: String, fbId: String, accessToken: String, userId: String, firstName: String, lastName: String, nickname: String, email: String, pictures: [String]) {
        self.userId = userId
        self.fbId = fbId
        self.accessToken = accessToken
        self.fbAuthtoken = fbAuthtoken
        self.firstName = firstName
        self.lastName = lastName
        self.nickname = nickname
        self.email = email
        self.picturesArr = pictures
        storeVariablesToNSUserDefault()
    }
    
    func resetCurrentCircle(currentCircleId: String){
        Me.user.currentCircleId = currentCircleId
        Me.user.prefs.setValue(currentCircleId, forKey: "currentCircleId")
    }
    
//    func resetFBAccessToken(fbAuthtoken: String){
//        Me.user.fbAuthtoken = fbAuthtoken
//        Me.user.prefs.setValue(fbAuthtoken, forKey: "fbAuthtoken")
//    }
    
    func resetBarrAccessToken(accessToken: String){
        Me.user.accessToken = accessToken
        Me.user.prefs.setValue(accessToken, forKey: "barrAuthToken")
    }
    
    func storeVariablesToNSUserDefault(){
        Me.user.prefs.setValue(Me.user.fbAuthtoken, forKey: "fbAuthtoken")
        Me.user.prefs.setValue(Me.user.fbId, forKey: "fbId")
        Me.user.prefs.setValue(Me.user.accessToken, forKey: "barrAuthToken")
        Me.user.prefs.setValue(Me.user.userId, forKey: "barrId")
        newestValidateInfo = true
    }
    
    func setVariablesFromNSUserDefault() -> Bool{
        if let fbAuth = Me.user.prefs.stringForKey("fbAuthtoken"), fbId = Me.user.prefs.stringForKey("fbId"), barrAuth = Me.user.prefs.stringForKey("barrAuthToken"), barrId = Me.user.prefs.stringForKey("barrId"){
            Me.user.userId = barrId
            Me.user.fbId = fbId
            Me.user.accessToken = barrAuth
            Me.user.fbAuthtoken = fbAuth
            return true
        } else {
            return false
        }
    }
    
    // MARK: FBSDK Call
    
    func makeFbGraphCall(parameters: [String: String], completion: (err: NSError?, response: JSON?) -> Void){
        print(Me.user.fbAuthtoken)
        let req = FBSDKGraphRequest(graphPath: "me", parameters: parameters, tokenString: Me.user.fbAuthtoken, version: nil, HTTPMethod: "GET")
        req.startWithCompletionHandler({ (connection, result, error : NSError!) -> Void in
            if(error == nil) {
                completion(err: nil, response: JSON(result))
            } else {
                completion(err: error, response: nil);
            }
        })
    }
    
    // MARK: CRUD Functionality
    
    /*func createUser(callback callback: (NSError?) -> Void){
        self.makeFbGraphCall(["fields":"email,first_name,last_name,picture"], completion:
            { (err, response) in
                if (err != nil) {
                    callback(err!);
                    return;
                }
                
                print(response!["picture"]["url"].rawString())
                
                if let firstName = response!["first_name"].rawString(), lastName = response!["last_name"].rawString(), email = response!["email"].rawString() {
                    
                    if let _ = Me.user.fbId, accessToken = Me.user.accessToken, userId = Me.user.userId {
                        
                        let body: [String:AnyObject] = ["fields":  ["firstName": firstName, "lastName": lastName, "email": email], "x_key" : userId, "access_token": accessToken]
                        
                        AlamoHelper.POST("api/v1/users/update/" + userId, parameters: body, completion: {response in
                            if let message = response["message"].string {
                                if message != "success" {
                                    callback(NSError(domain: "Failed to update user", code: 400, userInfo: nil));
                                } else {
                                    callback(nil);
                                }
                            }
                        })
                    }
                }
            }
        )
    }*/
    
    func updateUser(parameters: [String: AnyObject], completion: (NSError?) -> Void){
        let body: [String:AnyObject] = ["fields":  parameters];
        AlamoHelper.authorizedPost("api/v1/users/update/" + Me.user.userId!, parameters: body, completion: {
            (err, response) -> Void in
            if (err != nil) {
                completion(err);
                return;
            }
            
            else if (response!["message"].string != "success") {
                completion(NSError(domain: "Internal Server Error", code: 400, userInfo: nil));
                return;
            }
            
            completion(nil);
        })
        
    }
    
    func getUserAttrs(){
        if let userId = Me.user.userId {
            AlamoHelper.authorizedGet("api/v1/users/" + userId, parameters: [String: AnyObject](), completion: {
                err, response in
                if err != nil {
                    //TODO: handle err
                    return;
                }
                print(response)
                    Me.user.currentCircleId = response!["user"]["currentCircle"].rawString()
                    Me.user.firstName = response!["user"]["firstName"].rawString()
                    Me.user.lastName = response!["user"]["lastName"].rawString()
                    Me.user.email = response!["user"]["email"].rawString()
                    Me.user.picturesArr = response!["user"]["picture"].rawValue as? [String]
                print(Me.user.currentCircleId)
                print(Me.user.firstName)
                print(Me.user.lastName)
                print(Me.user.email)
                print(Me.user.picturesArr)
            });
        }
    }
}