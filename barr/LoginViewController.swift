//
//  LoginViewController.swift
//  barr
//
//  Created by Justin Hilliard on 2/13/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Alamofire

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBAction func loginFB(sender: AnyObject) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.loginBehavior = FBSDKLoginBehavior.Native
        loginToFacebookWithSuccess({}, andFailure: {_ in })
    }
    
    let facebookReadPermissions = ["public_profile", "email", "user_friends"]
    
    func loginToFacebookWithSuccess(successBlock: () -> Void, andFailure failureBlock: (NSError?) -> Void) {
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            //For debugging, when we want to ensure that facebook login always happens
            //FBSDKLoginManager().logOut()
            //Otherwise do:
            return
        }
        
        FBSDKLoginManager().logInWithReadPermissions(self.facebookReadPermissions, fromViewController: self, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
            if error != nil {
                //According to Facebook:
                //Errors will rarely occur in the typical login flow because the login dialog
                //presented by Facebook via single sign on will guide the users to resolve any errors.
                
                // Process error
                FBSDKLoginManager().logOut()
                failureBlock(error)
            } else if result.isCancelled {
                // Handle cancellations
                FBSDKLoginManager().logOut()
                failureBlock(nil)
            } else {
                // If you ask for multiple permissions at once, you
                // should check if specific permissions missing
                var allPermsGranted = true
                
                //result.grantedPermissions returns an array of _NSCFString pointers
                let grantedPermissions = Array(result.grantedPermissions).map( {"\($0)"} )
                for permission in self.facebookReadPermissions {
                    if !grantedPermissions.contains(permission) {
                        allPermsGranted = false
                        break
                    }
                }
                if allPermsGranted {
                    // Do work
                    let fbToken = result.token.tokenString
                    let fbUserID = result.token.userID
                    print(fbToken)
                    print(fbUserID)
                    //Send fbToken and fbUserID to your web API for processing, or just hang on to that locally if needed
                    //self.post("myserver/myendpoint", parameters: ["token": fbToken, "userID": fbUserId]) {(error: NSError?) ->() in
                    //	if error != nil {
                    //		failureBlock(error)
                    //	} else {
                    //		successBlock(maybeSomeInfoHere?)
                    //	}
                    //}
                    
                    successBlock()
                } else {
                    //The user did not grant all permissions requested
                    //Discover which permissions are granted
                    //and if you can live without the declined ones
                    
                    failureBlock((nil))
                }
            }
        })
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Load Page")
        
        if (FBSDKAccessToken.currentAccessToken() == nil){
            print("Not Logged in...")
            notLoggedIn()
        } else {
            print("Logged in...")
            notLoggedIn()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func notLoggedIn(){
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        let loginButton = FBSDKLoginButton()
        let signUpEmail = UITextField(frame: CGRect(x: (screenWidth * 0.125), y: (screenHeight * 0.5), width: screenWidth * 0.75, height: screenHeight * 0.1))
        signUpEmail.backgroundColor = UIColor.greenColor()
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        
        let X_Position:CGFloat = (screenWidth * 0.5) //use your X position here
        let Y_Position:CGFloat = (screenHeight * 0.75) //use your Y position here
        
        loginButton.frame = CGRectMake((X_Position-loginButton.frame.width/2), Y_Position, loginButton.frame.width, loginButton.frame.height)
        
        loginButton.delegate = self
        
        self.view.addSubview(loginButton)
        self.view.addSubview(signUpEmail)
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if (error == nil){
//            print("\(result.token.tokenString)")
//            print("\(result.token.expirationDate)")
            Auth.sendAuthRequest(result.token.tokenString)
//            print(User.createUser(result.token.tokenString))
            print("Login Complete...")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mapVC = storyboard.instantiateViewControllerWithIdentifier("TabVC")
            self.presentViewController(mapVC, animated: true, completion: nil)
        } else {
            print(error.localizedDescription)
        }
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out...")
    }
}