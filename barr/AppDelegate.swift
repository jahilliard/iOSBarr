//
//  AppDelegate.swift
//  barr
//
//  Created by Justin Hilliard on 2/10/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftyJSON
import GoogleMaps

let screenSize: CGRect = UIScreen.mainScreen().bounds
let readyNotification = "readyNotification";
@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func registerForPushNotifications(application: UIApplication) {
        // Request permission to present notifications
        let notificationSettings = UIUserNotificationSettings(
            forTypes: [.Badge, .Sound, .Alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .None {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        print("Device Token:", tokenString)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Failed to register:", error)
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        registerForPushNotifications(application);
        
        //App launch code
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        if FBSDKAccessToken.currentAccessToken() != nil {
            print("REFRESHING TOKEN");
            FBSDKAccessToken.refreshCurrentAccessToken( {
                (connection, result, error : NSError!) -> Void in
                    print("DOING AUTH");
                    print(Me.user.accessToken)
                    print(Me.user.userId)
                if (error != nil) {
                    //TODO: handle being unable to refresh token
                    return;
                }
                Auth.sendAuthRequest(FBSDKAccessToken.currentAccessToken().tokenString, completion: {
                    err, isCreated in
                    if ((err) != nil) {
                        //TODO: handle error case, server could not authenticate
                    } else {
                        NSNotificationCenter.defaultCenter().postNotificationName(readyNotification, object: self, userInfo: nil);
                        print("STARTING SOCKETS");
                        LocationTracker.tracker.startLocationTracking()
                        SocketManager.sharedInstance.open();
                    }
                })
            })
            print(Me.user.setVariablesFromNSUserDefault());
            
            let storyboard = UIStoryboard(name: "InitialScreen", bundle: nil)
            let initialViewController = storyboard.instantiateViewControllerWithIdentifier("InitialScreen")
            self.window?.rootViewController = initialViewController;
            self.window?.makeKeyAndVisible();
        } else {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let initialViewController = storyboard.instantiateViewControllerWithIdentifier("LoginScreen")
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        } 
        
        return true;
    }

    
    func application(app: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        SocketManager.sharedInstance.close();
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        SocketManager.sharedInstance.open();
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

