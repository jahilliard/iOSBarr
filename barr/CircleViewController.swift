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

class CircleViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UIPopoverPresentationControllerDelegate {
    
    let toggleBar: UIView = UIView()
    private let sectionInsets = UIEdgeInsets(top: 10.0, left: 0, bottom: 50.0, right: 0);
    
    var heartDepressed: Bool = false
    var pokeDepressed: Bool = false
    var memberArray : [UserInfo] = []
    
    @IBOutlet weak var circleCollection: UICollectionView!

    @IBOutlet weak var HeartButton: UIButton!
    
    @IBAction func onHeartButtonPress(sender: AnyObject) {
        print("heart Hit")
        if heartDepressed == true {
            heartDepressed = false
            self.HeartButton.backgroundColor = UIColor.whiteColor();
        } else {
            heartDepressed = true
            self.HeartButton.backgroundColor = UIColor.grayColor();
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
            self.PokeButton.backgroundColor = UIColor.grayColor();
        }
        
        self.makeMemberArray();
        self.circleCollection.reloadData();
    }
    
    func makeMemberArray() {
        self.memberArray = Circle.sharedInstance.memberArray.filter({self.shouldMemberDisplay($0)});
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeMemberArray();
        let req = FBSDKGraphRequest(graphPath: "me/photos", parameters: ["fields": "id, source"], tokenString: Me.user.fbAuthtoken, version: nil, HTTPMethod: "GET")
        req.startWithCompletionHandler({ (connection, result, error : NSError!) -> Void in
            if(error == nil) {
                let data = JSON(result)["data"].arrayValue;
                print(data.count);
                for photo in data {
                    print(photo["source"].string!);
                }
            } else {
                print("error \(error)")
            }
        })
        
        
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCircle:", name:CircleUpdateNotification, object: nil);
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    func updateCircle(notification : NSNotification){
        print("updateCircle Called");
        self.makeMemberArray();
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showProfile"{
            print("HERE");
            if let cell = sender as? UserPhotoCell, cellInfo = cell.userCellInfo, userInfo = cellInfo.user
            {
                let profileController = segue.destinationViewController as! UserProfileViewController;
                profileController.userInfo = userInfo;
                // This is the important part
                let popPC = profileController.popoverPresentationController;
                popPC!.delegate = self;
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

        if userInfo.pictures.count > 0 {
            let picURL = userInfo.pictures[0];
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
                }
            }
        } else {
            //TODO: set cell to default
        }
        
        cell.backgroundColor = UIColor.blueColor()
        return cell
    }
}
