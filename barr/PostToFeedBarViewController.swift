//
//  PostToFeedBarViewController.swift
//  barr
//
//  Created by Carl Lin on 4/30/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

class PostToFeedBarViewController: UIViewController {
    var parent: UIViewController! = nil;
    @IBOutlet weak var yourTabPicture: UIImageView!
    @IBAction func IBOutletvaronNewFeedEntryTappedUITapGestureRecognizer(sender: AnyObject) {
        if parent != nil {
            parent.performSegueWithIdentifier("toNewFeedEntry", sender: self);
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        //self.yourTabPicture.image = UIImage(imageLiteral: "defaultProfilePicture.jpg");
        if let imagesArr = Me.user.picturesArr where imagesArr.count > 0 && imagesArr[0] != "null"{
            Circle.getProfilePictureByURL(imagesArr[0], completion: {img in self.yourTabPicture.image = img});
        } else {
            self.yourTabPicture.image = UIImage(imageLiteral: "defaultProfilePicture.jpg");
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didMoveToParentViewController(parent: UIViewController?){
        self.parent = parent;
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
