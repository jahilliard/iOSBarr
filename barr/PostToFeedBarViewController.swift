//
//  PostToFeedBarViewController.swift
//  barr
//
//  Created by Carl Lin on 4/30/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

class PostToFeedBarViewController: UIViewController {
    @IBOutlet weak var yourTabPicture: UIImageView!
    @IBAction func IBOutletvaronNewFeedEntryTappedUITapGestureRecognizer(sender: AnyObject) {
        self.performSegueWithIdentifier("toNewFeedEntry", sender: self);
    }
    
    override func viewDidLoad() {
        if let imagesArr = Me.user.picturesArr where imagesArr.count > 0 {
            Circle.getProfilePictureByURL(imagesArr[0], completion: {img in self.yourTabPicture.image = img});
        } else {
            self.yourTabPicture.image = UIImage(imageLiteral: "defaultProfilePicture.jpg");
        }
        
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
