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

class LoginViewController: UIViewController {
    
    let facebookReadPermissions = ["public_profile", "email", "user_friends", "user_photos", "user_birthday"]
    
    @IBAction func loginFB(sender: AnyObject) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.loginBehavior = FBSDKLoginBehavior.Native
        loginToFacebookWithSuccess(
            { result in
                Auth.sendAuthRequest(result.token.tokenString){
                    (err, isCreated) in
                        if err != nil{
                            //TODO: handle when fails to auth with our server, notify user
                            //TEST by setting connection address to wrong string
                            err
                        } else {
                            if (isCreated) {
                                //TODO: move socket init into after info has been filled out by the user in additionalinfocontroller
                                print("STARTING SOCKETS");
                                SocketManager.sharedInstance.open();
                                
                                print("additional View")
                                /*let addInfoVC:AdditionalInfoViewController = AdditionalInfoViewController()
                                self.presentViewController(addInfoVC, animated: true, completion: nil)*/
                                //TODO: move this code into after additionalviewcontroller is finished
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let mapVC: UIViewController = storyboard.instantiateViewControllerWithIdentifier("TabVC");
                                self.presentViewController(mapVC, animated: true, completion: nil);
                            } else {
                                print("STARTING SOCKETS");
                                SocketManager.sharedInstance.open();
                                print("additional View")
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let mapVC: UIViewController = storyboard.instantiateViewControllerWithIdentifier("TabVC")
                                self.presentViewController(mapVC, animated: true, completion: nil)
                            }
                        }
                }
            }, andFailure: {
                //TODO: when fb credentials/login fail
                err in
                    err
            }
        )
    }
    
    func loginToFacebookWithSuccess(successBlock: (FBSDKLoginManagerLoginResult) -> Void, andFailure failureBlock: (NSError?) -> Void) {
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            //For debugging, when we want to ensure that facebook login always happens
            //FBSDKLoginManager().logOut()
            //Otherwise do:
            return;
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

                    successBlock(result)
                } else {
                    failureBlock((nil))
                }
            }
        })
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}