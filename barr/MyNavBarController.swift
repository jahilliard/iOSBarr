//
//  MyNavBarController.swift
//  barr
//
//  Created by Justin Hilliard on 4/4/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

class MyNavBarController: UINavigationController, UINavigationControllerDelegate {
    override func viewDidLoad() {
        UINavigationBar.appearance().tintColor = UIColor(red: 64, green: 78, blue: 146)

        UINavigationBar.appearance().barTintColor =  UIColor(red: 255, green: 255, blue: 255)
        
        let topDiv = UIView(frame: CGRect(origin: CGPoint(x: 0, y: self.navigationBar.frame.height), size: CGSize(width: self.navigationBar.frame.width, height: 2)))
        topDiv.backgroundColor = UIColor(red: 64, green: 78, blue: 146)
        self.navigationBar.addSubview(topDiv)
        
        let attributes = [NSFontAttributeName : UIFont(name: "PrintBold", size: 28)!, NSForegroundColorAttributeName : UIColor(red: 64, green: 78, blue: 146)]
        self.navigationBar.titleTextAttributes = attributes
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        let unselectedColor = UIColor(red: 226, green: 228, blue: 238)
//        
//        for item in self.tabBar.items! {
//            item.image = item.selectedImage?.imageWithColor(unselectedColor).imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
//        }
    }
}
