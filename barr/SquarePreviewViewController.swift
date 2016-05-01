//
//  SquarePreviewViewController.swift
//  barr
//
//  Created by Carl Lin on 4/30/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

class SquarePreviewViewController: UIViewController {
    var locationId: String!;
    var tabBar: UITabBarController!;
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    @IBAction func onViewFeedButtonPress(sender: UIButton) {
        FeedManager.sharedInstance.updateFeedId(locationId);
        self.tabBar!.selectedIndex = 0;
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
