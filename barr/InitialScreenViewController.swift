//
//  InitialScreenViewController.swift
//  barr
//
//  Created by Carl Lin on 3/22/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

class InitialScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "displayMain:", name: readyNotification, object: nil);
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    func displayMain(notification : NSNotification){
        print("displayMain Called");
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mapVC: UIViewController = storyboard.instantiateViewControllerWithIdentifier("TabVC")
        self.presentViewController(mapVC, animated: true, completion: nil);
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
