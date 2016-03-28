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

class SelectPhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, InfoToPhotoDelegate {
    
    var indexToMod: Int?
    
    var morePictsPath: String?
    
    var isUserPhotos: Bool?
    var albumName: String?
    var albumId: String?
    
    var imageCollection: UICollectionView!
    var picturesArr: [JSON] = []
    
    let imgCache: NSCache = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 100, left: 0, bottom:5, right: 5)
        layout.itemSize = CGSize(width: screenSize.width*0.3, height: screenSize.width*0.3)
        
        imageCollection = UICollectionView(frame: CGRect(x: 5, y: 100, width: self.view.frame.width-5, height: self.view.frame.height-100), collectionViewLayout: layout)
        imageCollection.dataSource = self
        imageCollection.delegate = self
        imageCollection.registerClass(FacebookPhotoCell.self, forCellWithReuseIdentifier: "Cell")
        imageCollection.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(imageCollection)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picturesArr.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! FacebookPhotoCell
        
        if (indexPath.row == picturesArr.count - 1) {
            if morePictsPath != "null" {
                getFBPhotos(morePictsPath!)
            }
            print(morePictsPath)
        }
        
        let picObj = self.picturesArr[indexPath.item]
        if let pictId = picObj["id"].rawString(), pictURL = picObj["source"].rawString() {
            if let fbCellImgInfo = imgCache.objectForKey(pictId){
                let fbImgInfo = fbCellImgInfo as! FacebookPhotoCellInfo
                cell.setFbImgInfo(fbImgInfo)
            } else {
                DownloadImage.downloadImage(NSURL(string: pictURL)!) {
                    img in
                    let fbCellImgInfo = FacebookPhotoCellInfo(imgURL: pictURL, pictId: pictId, img: img, indexPath:indexPath)
                    cell.setFbImgInfo(fbCellImgInfo)
                    self.imgCache.setObject(fbCellImgInfo, forKey: pictId)
                }
            }
        }
        
        cell.backgroundColor = UIColor.orangeColor()
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell: FacebookPhotoCell = collectionView.cellForItemAtIndexPath(indexPath)! as! FacebookPhotoCell
        
        Me.user.picturesArr![self.indexToMod!] = (cell.fbCellInfo?.imgURL)!
        print(Me.user.picturesArr)
        
        func callback(err: NSError?) {
            if err != nil {
                //TODO: notify user
                Me.user.updateUser(["picture": Me.user.picturesArr!], completion: callback);
                return;
            }
        }
        
        Me.user.updateUser(["picture": Me.user.picturesArr!], completion: callback);
        
        let vcArr = self.navigationController?.viewControllers
        self.navigationController!.popToViewController(vcArr![vcArr!.count - 3], animated: true);
    }
    
    func getFBPhotos(path: String) {
            let req = FBSDKGraphRequest(graphPath: path, parameters: ["fields": "id, source"], tokenString: Me.user.fbAuthtoken, version: nil, HTTPMethod: "GET")
            req.startWithCompletionHandler({ (connection, result, error : NSError!) -> Void in
                if(error == nil) {
                    if self.picturesArr.count == 0 {
                        self.picturesArr = JSON(result)["data"].arrayValue
                    } else {
                        for item in JSON(result)["data"].arrayValue {
                            self.picturesArr.append(item);
                        }
                    }
                    print(self.picturesArr.count)
                    print(JSON(result)["paging"]["next"].rawString())
                    if let newPath = JSON(result)["paging"]["next"].rawString() {
                        if newPath != "null" {
                            self.morePictsPath = newPath.substringFromIndex(newPath.startIndex.advancedBy(32))
                            self.imageCollection.reloadData()
                        } else {
                            if self.morePictsPath == nil {
                                self.imageCollection.reloadData()
                            }
                            self.morePictsPath = newPath
                            
                        }
                    }
                } else {
                    print("error \(error)")
                }
            })
    }
    
    func sendAlbumAndIndexInfo(isUserPhotos: Bool, albumName: String, albumId: String, index: Int) {
        self.isUserPhotos = isUserPhotos
        self.albumName = albumName
        self.albumId = albumId
        self.indexToMod = index
        if (isUserPhotos == true) {
            getFBPhotos("me/photos")
        } else {
            getFBPhotos(albumId + "/photos")
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
    }
    
}



