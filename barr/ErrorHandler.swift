//
//  ErrorHandler.swift
//  barr
//
//  Created by Justin Hilliard on 2/23/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

struct ErrorHandler {
    
    static func buidErrorView(err: Bool){
        let errorView = UIView(frame: CGRect(origin: CGPoint(x: 0,y: 0), size: CGSize(width: screenSize.width, height: screenSize.height)))
        errorView.alpha = 0.5
        errorView.backgroundColor = UIColor.blackColor()
        print("Trying to throw Error Screen")
        if let topController = UIApplication.topViewController() {
            print("Top View defined ")
            topController.view.addSubview(errorView)
        }
    }
    
    static func showEventsAcessDeniedAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message,
            preferredStyle: .Alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .Default) {
            (alertAction) in
                if let appSettings = NSURL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(appSettings)
            }
        }
        alertController.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        if let topController = UIApplication.topViewController() {
            print("Top View defined ")
            topController.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}