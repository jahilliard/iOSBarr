//
//  ReturnToSquareFeedViewController.swift
//  barr
//
//  Created by Carl Lin on 4/30/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

class ReturnToSquareFeedViewController: UIViewController {
    @IBOutlet weak var yourTabPicture: UIImageView!
    @IBAction func returnToSquareButtonPress(sender: AnyObject) {
        FeedManager.sharedInstance.returnToOriginalFeed();
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
