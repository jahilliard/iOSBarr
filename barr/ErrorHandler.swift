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
}