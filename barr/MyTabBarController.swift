//
//  MyTabBarController.swift
//  barr
//
//  Created by Justin Hilliard on 4/2/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController, UINavigationControllerDelegate {
    override func viewDidLoad() {
        // Sets the default color of the icon of the selected UITabBarItem and Title   
        UITabBar.appearance().tintColor = UIColor(red: 64, green: 78, blue: 146)
        
//            UIColor(colorLiteralRed: 197.0, green: 201.0, blue: 222.0, alpha: 1.0)
        
        // Sets the default color of the background of the UITabBar
        UITabBar.appearance().barTintColor =  UIColor(red: 255, green: 255, blue: 255)
//        UITabBar.appearance()
        
        UITabBar.appearance().selectionIndicatorImage = UIImage().makeImageWithColorAndSize(UIColor(red: 197, green: 201, blue: 222), size: CGSizeMake(tabBar.frame.width/5, tabBar.frame.height))

        let topDiv = UIView(frame: CGRect(origin: CGPoint(x: 0, y: -2), size: CGSize(width: self.tabBar.frame.width, height: 2)))
        topDiv.backgroundColor = UIColor(red: 64, green: 78, blue: 146)
        self.tabBar.addSubview(topDiv)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        let unselectedColor = UIColor(red: 226, green: 228, blue: 238)
        
        for item in self.tabBar.items! {
            item.image = item.selectedImage?.imageWithColor(unselectedColor).imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        }
    }
}