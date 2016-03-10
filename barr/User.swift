//
//  User.swift
//  barr
//
//  Created by Justin Hilliard on 2/10/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

//import Foundation
//import Alamofire
//import SwiftyJSON
//import FBSDKCoreKit
//
//class User {
//    
//    var email: String?
//    var fbId: String?
//    var fbAuthtoken: String?
//    var userId: String?
//    var accessToken: String?
//    
//    var nickName: String?
//    var age: Int?
//    
//    static let prefs = NSUserDefaults.standardUserDefaults()
//    
//    init(){
//        if let fbAuth = User.prefs.stringForKey("fbAuthtoken"), fbId = User.prefs.stringForKey("fbId"), barrAuth = User.prefs.stringForKey("barrAuthToken"), barrId = User.prefs.stringForKey("barrId"){
//            self.userId = barrId
//            self.fbId = fbId
//            self.accessToken = barrAuth
//            self.fbAuthtoken = fbAuth
//            return true
//        } else {
//            return false
//        }
//    }
//    
//    func setVariables(fbAuthtoken: String, fbId: String, accessToken: String, userId: String) {
//        self.userId = userId
//        self.fbId = fbId
//        self.accessToken = accessToken
//        self.fbAuthtoken = fbAuthtoken
//        storeVariablesToNSUserDefault()
//    }
//    
//    func storeVariablesToNSUserDefault(){
//        User.prefs.setValue(self.fbAuthtoken, forKey: "fbAuthtoken")
//        User.prefs.setValue(self.fbId, forKey: "fbId")
//        User.prefs.setValue(self.accessToken, forKey: "barrAuthToken")
//        User.prefs.setValue(self.userId, forKey: "barrId")
//    }
//    
//    func setVariablesToNSUserDefault() -> Bool{
//        if let fbAuth = User.prefs.stringForKey("fbAuthtoken"), fbId = User.prefs.stringForKey("fbId"), barrAuth = User.prefs.stringForKey("barrAuthToken"), barrId = User.prefs.stringForKey("barrId"){
//                self.userId = barrId
//                self.fbId = fbId
//                self.accessToken = barrAuth
//                self.fbAuthtoken = fbAuth
//                return true
//        } else {
//            return false
//        }
//    }
//    
//    func makeFbGraphCall(parameters: [String: String], completion: (response: JSON) -> Void){
//        let req = FBSDKGraphRequest(graphPath: "me", parameters: parameters, tokenString: self.fbAuthtoken, version: nil, HTTPMethod: "GET")
//        req.startWithCompletionHandler({ (connection, result, error : NSError!) -> Void in
//            if(error == nil) {
//                completion(response: JSON(result))
//            } else {
//                print("error \(error)")
//            }
//        })
//    }
//    
//    func updateUser(parameters: [String: String]){
//        let body: [String:AnyObject] = ["fields":  parameters, "fbId" : self.fbId!, "access_token": self.accessToken!]
//        AlamoHelper.POST("api/v1/users/update/" + self.userId!, parameters: body, completion: {
//            (response) -> Void in
//                print("\(response["message"].rawString())")
//        })
//    }
//    
//    static func getNameEmail(fbAuthtoken: String, completion: (name: String, email:String) -> User){
//        let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email,name"], tokenString: fbAuthtoken, version: nil, HTTPMethod: "GET")
//        req.startWithCompletionHandler({ (connection, result, error : NSError!) -> Void in
//            if(error == nil)
//            {
//                print("result \(result)")
//                completion(name: result["name"] as! String, email: result["email"] as! String)
//            }
//            else
//            {
//                print("error \(error)")
//            }
//        })
//    }
//    
//}
