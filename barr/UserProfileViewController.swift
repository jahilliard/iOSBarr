//
//  UserProfileViewController.swift
//  barr
//
//  Created by Carl Lin on 3/28/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserProfileViewController: UIViewController {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var pokeButton: UIButton!
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var heartButton: UIButton!
    
    var userInfo : UserInfo = UserInfo(userInfo: JSON(NSDictionary(dictionary: [:])));
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nickName.text = userInfo.nickname;
        //load the photos in
        if self.userInfo.pictures.count > 0 {
            let picURL = userInfo.pictures[0];
            if let img = Circle.sharedInstance.userCellPhotoInfoCache.objectForKey(picURL) as? UIImage{
                self.profilePicture.image = img;
            } else {
                if let downloadURL = NSURL(string: picURL) {
                    DownloadImage.downloadImage(downloadURL) {
                        img in
                        self.profilePicture.image = img;
                        Circle.sharedInstance.userCellPhotoInfoCache.setObject(img, forKey: picURL)
                    }
                } else {
                    //TODO: set cell to default
                }
            }
        }
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
