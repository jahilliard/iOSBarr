//
//  CircleViewController.swift
//  barr
//
//  Created by Justin Hilliard on 2/26/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import SwiftyJSON

protocol ChatDelegate {
    // protocol definition goes here
    func displayChat(userInfo: UserInfo);
}

class CircleViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UIPopoverPresentationControllerDelegate, ChatDelegate {
    
    let toggleBar: UIView = UIView()
    private let sectionInsets = UIEdgeInsets(top: 10.0, left: 0, bottom: 50.0, right: 0);
    
    var heartDepressed: Bool = false
    var pokeDepressed: Bool = false
    var memberArray : [UserInfo] = []
    
    @IBOutlet weak var circleCollection: UICollectionView!

    @IBOutlet weak var HeartButton: UIButton!
    //@IBOutlet weak var joinCircleFail: UIButton!
    
    @IBAction func onHeartButtonPress(sender: AnyObject) {
        print("heart Hit")
        if heartDepressed == true {
            heartDepressed = false
            self.HeartButton.backgroundColor = UIColor.whiteColor();
        } else {
            heartDepressed = true
            self.HeartButton.backgroundColor = UIColor.init(red: 223, green: 226, blue: 237);
        }
        
        self.makeMemberArray();
        self.circleCollection.reloadData();
    }
    @IBOutlet weak var PokeButton: UIButton!
    
    @IBAction func onPokeButtonPress(sender: AnyObject) {
        print("poke Hit")
        if pokeDepressed == true {
            pokeDepressed = false
            self.PokeButton.backgroundColor = UIColor.whiteColor();
        } else {
            pokeDepressed = true
            self.PokeButton.backgroundColor = UIColor.init(red: 223, green: 226, blue: 237);
        }
        
        self.makeMemberArray();
        self.circleCollection.reloadData();
    }
    
    func makeMemberArray() {
        self.memberArray = Circle.sharedInstance.memberArray.filter({self.shouldMemberDisplay($0)});
        print(Circle.sharedInstance.memberArray.count);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if let f_name = Me.user.firstName, l_name = Me.user.lastName {
//            self.navigationItem.title = "\(f_name) \(l_name)";
//        } else {
//            self.navigationItem.title = "Square";
//        }
        self.navigationItem.title = "Square";
        //if (Circle.sharedInstance.circleId != "") {
            //joinCircleFail.hidden = true
            self.makeMemberArray();
            //        let req = FBSDKGraphRequest(graphPath: "me/photos", parameters: ["fields": "id, source"], tokenString: Me.user.fbAuthtoken, version: nil, HTTPMethod: "GET")
            //        req.startWithCompletionHandler({ (connection, result, error : NSError!) -> Void in
            //            if(error == nil) {
            //                let data = JSON(result)["data"].arrayValue;
            //                print(data.count);
            //                for photo in data {
            //                    print(photo["source"].string!);
            //                }
            //            } else {
            //                print("error \(error)")
            //            }
            //        })
            
            
            /*let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
             layout.sectionInset = UIEdgeInsets(top: 100, left: 0, bottom: 1, right: 0)
             let picSize = screenSize.width*0.33 - 0.5
             layout.itemSize = CGSize(width: picSize, height: picSize)
             
             circleCollection = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)*/
            self.circleCollection.dataSource = self
            self.circleCollection.delegate = self
            /*self.circleCollection.registerClass(UserPhotoCell.self, forCellWithReuseIdentifier: "UserPhotoCell")*/
            self.circleCollection.backgroundColor = UIColor.whiteColor()
            //self.view.addSubview(circleCollection)
            defineToggleView()
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CircleViewController.updateCircle(_:)), name:CircleUpdateNotification, object: nil);
        //} else {
            /*if let lat = LocationTracker.tracker.currentCoord?.latitude, long = LocationTracker.tracker.currentCoord?.longitude{
                Circle.addMemberToCircleByLocation(lat, lon: long) {
                    res in
                    
                }
 
        }*/
        
    }
    
    
    /*@IBAction func joinCircleFailAction(sender: AnyObject) {
        
    }*/
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    func updateCircle(notification : NSNotification){
        self.makeMemberArray();
        print(memberArray.count);
        self.circleCollection.reloadData();
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: screenSize.width * 0.33 - 0.5, height: screenSize.width * 0.33 - 0.5);
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return sectionInsets
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0;
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0;
    }
    
    func defineToggleView(){
        /*toggleBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: screenSize.size.height*0.15)
        toggleBar.backgroundColor = UIColor.blackColor()
        heartButton.frame = CGRect(x: 0, y: 0, width: 70, height: 50)
        pokeButton.frame = CGRect(x: toggleBar.frame.size.width*0.5, y: 0, width: 70, height: 50)
        heartButton.addTarget(self, action: "heartButtonPressed:", forControlEvents: .TouchUpInside)
        pokeButton.addTarget(self, action: "pokeButtonPressed:", forControlEvents: .TouchUpInside)
        heartButton.backgroundColor = UIColor.purpleColor()
        pokeButton.backgroundColor = UIColor.orangeColor()
        toggleBar.addSubview(heartButton)
        toggleBar.addSubview(pokeButton)
        self.view.addSubview(toggleBar)*/
    }
    
    func shouldMemberDisplay(member: UserInfo) -> Bool {
        if self.heartDepressed && (member.otherOffers[.HEART] == nil || !member.otherOffers[.HEART]!){
            return false;
        }
        
        if self.pokeDepressed && (member.otherOffers[.POKE] == nil || !member.otherOffers[.POKE]!){
            return false;
        }
        
        return true;
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.memberArray.count;
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
            performSegueWithIdentifier("showProfile", sender: cell)
        } else {
            // Error indexPath is not on screen: this should never happen.
        }
    }
    
    func displayChat(userInfo: UserInfo) {
        performSegueWithIdentifier("toChat", sender: userInfo);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showProfile" {
            if let cell = sender as? UserPhotoCell {
                print(cell);
                if let cellInfo = cell.userCellInfo {
                    print(cellInfo);
                    if let userInfo = cellInfo.user {
                        print(userInfo);
                    }
                }
            }
            
            if let cell = sender as? UserPhotoCell, cellInfo = cell.userCellInfo, userInfo = cellInfo.user
            {
                let profileController = segue.destinationViewController as! UserProfileViewController;
                profileController.userInfo = userInfo;
                profileController.chatDelegate = self;
                // This is the important part
                let popPC = profileController.popoverPresentationController;
                popPC!.delegate = self;
            }
        }
        
        else if segue.identifier == "toChat" {
            if let userInfo = sender as? UserInfo {
                let chatViewController = segue.destinationViewController as! ChatViewController;
                chatViewController.otherUserInfo = userInfo;
                chatViewController.hidesBottomBarWhenPushed = true;
            }
        }
    }
    
    func adaptivePresentationStyleForPresentationController(
        controller: UIPresentationController) -> UIModalPresentationStyle {
            return .None
    }
    
    /*func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        print("dismissed")
    }*/
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("UserPhotoCell", forIndexPath: indexPath) as! UserPhotoCell
        
        //look through the user Arr
        let userInfo = self.memberArray[indexPath.row];

        if userInfo.pictures.count > 0 && userInfo.pictures[0] != "null" {
            let picURL = userInfo.pictures[0];
            print(picURL);
            if let img = Circle.sharedInstance.userCellPhotoInfoCache.objectForKey(picURL) as? UIImage{
                let userCellImgInfo = UserCellPhotoInfo(user: userInfo, indexPath: indexPath, img: img, imgURL: picURL);
                cell.setFbImgInfo(userCellImgInfo);
            } else {
                if let downloadURL = NSURL(string: picURL) {
                    DownloadImage.downloadImage(downloadURL) {
                        img in
                        let userCellImgInfo = UserCellPhotoInfo(user: userInfo, indexPath: indexPath, img: img, imgURL: picURL);
                        cell.setFbImgInfo(userCellImgInfo);
                        Circle.sharedInstance.userCellPhotoInfoCache.setObject(img, forKey: picURL)
                    }
                } else {
                    //TODO: set cell to default
                    let userCellImgInfo = UserCellPhotoInfo(user: userInfo, indexPath: indexPath, img: UIImage(imageLiteral: "defaultProfilePicture.jpg"), imgURL: "default");
                    cell.setFbImgInfo(userCellImgInfo);
                }
            }
        } else {
            //TODO: set cell to default
            print(userInfo);
            let userCellImgInfo = UserCellPhotoInfo(user: userInfo, indexPath: indexPath, img: UIImage(imageLiteral: "defaultProfilePicture.jpg"), imgURL: "default");
            cell.setFbImgInfo(userCellImgInfo);
        }
        
        cell.backgroundColor = UIColor.whiteColor();
        return cell;
    }
}
