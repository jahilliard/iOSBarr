//
//  SelectPhotos.swift
//  barr
//
//  Created by Justin Hilliard on 3/5/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import FBSDKCoreKit
import UIKit
import SwiftyJSON

class SelectPhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    static var imageCollection: UICollectionView!
    var picturesArr: [JSON] = []
    
    static let imgCache: NSCache = NSCache()
    
    static var photoArr: [FacebookPhotoCellInfo?] = [nil, nil, nil]
    static var currentIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getFBAlbums()
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 100, left: 0, bottom:5, right: 5)
        layout.itemSize = CGSize(width: screenSize.width*0.3, height: screenSize.width*0.3)
        
        SelectPhotosViewController.imageCollection = UICollectionView(frame: CGRect(x: 5, y: 0, width: self.view.frame.width-5, height: self.view.frame.height), collectionViewLayout: layout)
        SelectPhotosViewController.imageCollection.dataSource = self
        SelectPhotosViewController.imageCollection.delegate = self
        SelectPhotosViewController.imageCollection.registerClass(FacebookPhotoCell.self, forCellWithReuseIdentifier: "Cell")
        SelectPhotosViewController.imageCollection.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(SelectPhotosViewController.imageCollection)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picturesArr.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! FacebookPhotoCell
        
        let picObj = self.picturesArr[indexPath.item]
        if let pictId = picObj["id"].rawString(), pictURL = picObj["source"].rawString() {
            if let fbCellImgInfo = SelectPhotosViewController.imgCache.objectForKey(pictId){
                let fbImgInfo = fbCellImgInfo as! FacebookPhotoCellInfo
                cell.setFbImgInfo(fbImgInfo)
            } else {
                DownloadImage.downloadImage(NSURL(string: pictURL)!) {
                    img in
                    let fbCellImgInfo = FacebookPhotoCellInfo(imgURL: pictURL, pictId: pictId, img: img, indexPath:indexPath)
                    cell.setFbImgInfo(fbCellImgInfo)
                    SelectPhotosViewController.imgCache.setObject(fbCellImgInfo, forKey: pictId)
                }
            }
        }
        
        cell.backgroundColor = UIColor.orangeColor()
        return cell
    }
    
    func getFBAlbums() {
        let req = FBSDKGraphRequest(graphPath: "me/photos", parameters: ["fields": "id, source"], tokenString: Me.user.fbAuthtoken, version: nil, HTTPMethod: "GET")
        req.startWithCompletionHandler({ (connection, result, error : NSError!) -> Void in
            if(error == nil) {
                self.picturesArr = JSON(result)["data"].arrayValue
                SelectPhotosViewController.imageCollection.reloadData()
            } else {
                print("error \(error)")
            }
        })
    }
    
    static func updatePhotoArr(fbCellInfo: FacebookPhotoCellInfo){
        if let oldPic = photoArr[currentIndex]{
            oldPic.hasBorder = false
            oldPic.selPhotoIndex = -1
            imgCache.setObject(oldPic, forKey: oldPic.pictId)
            if let cell = SelectPhotosViewController.imageCollection.cellForItemAtIndexPath(oldPic.indexPath) as?FacebookPhotoCell {
                cell.deleteBorder()
            }
        }
        
        fbCellInfo.hasBorder = true
        fbCellInfo.selPhotoIndex = currentIndex
        photoArr[currentIndex] = fbCellInfo
        imgCache.setObject(fbCellInfo, forKey: fbCellInfo.pictId)
        
        if currentIndex == 2 {
            currentIndex = 0
        } else {
            currentIndex++
        }
    }
    
}



