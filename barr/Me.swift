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
    
    var email: String?
    var fbId: String?
    var fbAuthtoken: String?
    var userId: String?
    var accessToken: String?
    
    var nickName: String?
    var age: Int?
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    private init() {}
    
    func setVariables(fbAuthtoken: String, fbId: String, accessToken: String, userId: String) {
        Me.user.userId = userId
        Me.user.fbId = fbId
        Me.user.accessToken = accessToken
        Me.user.fbAuthtoken = fbAuthtoken
        storeVariablesToNSUserDefault()
    }
    
    func resetFBAccessToken(fbAuthtoken: String){
        Me.user.fbAuthtoken = fbAuthtoken
        Me.user.prefs.setValue(fbAuthtoken, forKey: "fbAuthtoken")
    }
    
    func resetBarrAccessToken(accessToken: String){
        Me.user.accessToken = accessToken
        Me.user.prefs.setValue(accessToken, forKey: "barrAuthToken")
    }
    
    func storeVariablesToNSUserDefault(){
        Me.user.prefs.setValue(Me.user.fbAuthtoken, forKey: "fbAuthtoken")
        Me.user.prefs.setValue(Me.user.fbId, forKey: "fbId")
        Me.user.prefs.setValue(Me.user.accessToken, forKey: "barrAuthToken")
        Me.user.prefs.setValue(Me.user.userId, forKey: "barrId")
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
    
    func makeFbGraphCall(parameters: [String: String], completion: (response: JSON) -> Void){
        print(Me.user.fbAuthtoken)
        let req = FBSDKGraphRequest(graphPath: "me", parameters: parameters, tokenString: Me.user.fbAuthtoken, version: nil, HTTPMethod: "GET")
        req.startWithCompletionHandler({ (connection, result, error : NSError!) -> Void in
            if(error == nil) {
                completion(response: JSON(result))
            } else {
                print("error \(error)")
            }
        })
    }
    
    func printVals(){
        print(Me.user.fbAuthtoken!)
        print(Me.user.userId!)
        print(Me.user.accessToken!)
        print(Me.user.fbId!)
    }
    
    // MARK: CRUD Functionality
    
    func createUser(){
        makeFbGraphCall(["fields":"email,first_name,last_name,picture"], completion:
            { (response) in
                print(response["picture"]["url"].rawString())
                
                if let firstName = response["first_name"].rawString(), lastName = response["last_name"].rawString(), email = response["email"].rawString() {
                    
                    if let _ = Me.user.fbId, accessToken = Me.user.accessToken, userId = Me.user.userId {
                        
                        let body: [String:AnyObject] = ["fields":  ["firstName": firstName, "lastName": lastName, "email": email], "x_key" : userId, "access_token": accessToken]
                        
                        AlamoHelper.POST("api/v1/users/update/" + userId, parameters: body, completion: nil)
                    }
                    
                }
            }
        )
    }
    
    func updateUser(parameters: [String: String]){
        let body: [String:AnyObject] = ["fields":  parameters, "fbId" : Me.user.userId!, "access_token": Me.user.accessToken!]
        AlamoHelper.POST("api/v1/users/update/" + Me.user.userId!, parameters: body, completion: {
            (response) -> Void in
            print("\(response["message"].rawString())")
        })
        
    }
    
}