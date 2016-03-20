//
//  CircleViewController.swift
//  barr
//
//  Created by Justin Hilliard on 2/26/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

class CircleViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let toggleBar: UIView = UIView()
    var circleCollection: UICollectionView!
    
    let heartButton: UIButton = UIButton()
    let drinkButton: UIButton = UIButton()
    
    var heartDepressed: Bool = false
    var drinkDepressed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 100, left: 0, bottom: 1, right: 0)
        let picSize = screenSize.width*0.33 - 0.5
        layout.itemSize = CGSize(width: picSize, height: picSize)
        
        circleCollection = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        circleCollection.dataSource = self
        circleCollection.delegate = self
        circleCollection.registerClass(UserPhotoCell.self, forCellWithReuseIdentifier: "Cell")
        circleCollection.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(circleCollection)
        defineToggleView()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0;
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0;
    }
    
    func defineToggleView(){
        toggleBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: screenSize.size.height*0.15)
        toggleBar.backgroundColor = UIColor.blackColor()
        heartButton.frame = CGRect(x: 0, y: 0, width: 70, height: 50)
        drinkButton.frame = CGRect(x: toggleBar.frame.size.width*0.5, y: 0, width: 70, height: 50)
        heartButton.addTarget(self, action: "heartButtonPressed:", forControlEvents: .TouchUpInside)
        drinkButton.addTarget(self, action: "drinkButtonPressed:", forControlEvents: .TouchUpInside)
        heartButton.backgroundColor = UIColor.purpleColor()
        drinkButton.backgroundColor = UIColor.orangeColor()
        toggleBar.addSubview(heartButton)
        toggleBar.addSubview(drinkButton)
        self.view.addSubview(toggleBar)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 21
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! UserPhotoCell
        
        //look through the user Arr
        
        //pull the user from the DB
        
//        if let pictId = picObj["id"].rawString(), pictURL = picObj["source"].rawString() {
//            if let fbCellImgInfo = SelectPhotosViewController.imgCache.objectForKey(pictId){
//                let fbImgInfo = fbCellImgInfo as! FacebookPhotoCellInfo
//                cell.setFbImgInfo(fbImgInfo)
//            } else {
//                DownloadImage.downloadImage(NSURL(string: pictURL)!) {
//                    img in
//                    let fbCellImgInfo = FacebookPhotoCellInfo(imgURL: pictURL, pictId: pictId, img: img, indexPath:indexPath)
//                    cell.setFbImgInfo(fbCellImgInfo)
//                    SelectPhotosViewController.imgCache.setObject(fbCellImgInfo, forKey: pictId)
//                }
//            }
//        }
        cell.backgroundColor = UIColor.blueColor()
        return cell
    }
    
    func getUsersInCurrentCirle(circleId: String) {
        //call the API
    }
    
    func heartButtonPressed(sender: UIButton!){
        print("heart Hit")
        if heartDepressed == true {
           heartDepressed = false
        } else {
           heartDepressed = true
        }
    }
    
    func drinkButtonPressed(sender: UIButton!){
        print("drink Hit")
        if drinkDepressed == true {
            drinkDepressed = false
        } else {
            drinkDepressed = true
        }
    }
    
}
