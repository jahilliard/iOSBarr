//
//  AccountViewController.swift
//  barr
//
//  Created by Justin Hilliard on 2/13/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class AccountViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print("Load Page")
        let logOutBut: UIButton = UIButton(frame: CGRect(x: self.view.frame.width*0.5, y: self.view.frame.height*0.5, width: 200, height: 200))
        logOutBut.backgroundColor = UIColor.greenColor()
        logOutBut.titleLabel?.text = "Logout"
        logOutBut.addTarget(self, action: "fbLogOut:", forControlEvents: .TouchUpInside)
        self.view.addSubview(logOutBut)
    }
    
    func fbLogOut(sender: UIButton!){
        if (FBSDKAccessToken.currentAccessToken() != nil){
            FBSDKLoginManager().logOut()
            sendToLogin()
        } else {
            sendToLogin()
        }
    }
    
    func sendToLogin(){
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let mapVC: UIViewController = storyboard.instantiateViewControllerWithIdentifier("LoginScreen")
        self.presentViewController(mapVC, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}