//
//  AccountViewController.swift
//  barr
//
//  Created by Justin Hilliard on 2/13/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

protocol cellIndexToAlbumDelegate{
    func cellIndexToAlbum(index: Int)
}

class AccountViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AccountPictureCellDelegate {
    
    var delegate: cellIndexToAlbumDelegate?
    var picModIndex: Int?
    
    var photoCollection: UICollectionView!
    let imgCache: NSCache = NSCache()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true);
        photoCollection.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsets(top: 100, left: 0, bottom: 200, right: 0)
        let picSize = screenSize.width*0.6
        layout.itemSize = CGSize(width: picSize, height: picSize)
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        photoCollection = UICollectionView(frame: CGRect(origin: CGPoint(x: 0, y: self.navigationController!.navigationBar.frame.size.height), size: CGSize(width: screenSize.width, height: screenSize.height*0.5)), collectionViewLayout: layout)
        photoCollection.dataSource = self
        photoCollection.delegate = self
        photoCollection.registerClass(AccountPictureCell.self, forCellWithReuseIdentifier: "Cell")
        photoCollection.backgroundColor = UIColor.greenColor()
        self.view.addSubview(photoCollection)
    }
    
    func sendToLogin(){
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let mapVC: UIViewController = storyboard.instantiateViewControllerWithIdentifier("LoginScreen")
        self.presentViewController(mapVC, animated: true, completion: nil)
    }
    
    
    @IBAction func logoutButton(sender: AnyObject) {
        if (FBSDKAccessToken.currentAccessToken() != nil){
            FBSDKLoginManager().logOut()
            sendToLogin()
        } else {
            sendToLogin()
        }
    }
    
    func preformSegue(accountPicture: AccountPictureCell){
        picModIndex = accountPicture.index
        self.performSegueWithIdentifier("selectAlb", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "selectAlb") {
            let selectAlb: SelectAlbumViewController = segue.destinationViewController as! SelectAlbumViewController
            delegate = selectAlb
            if delegate != nil {
                delegate!.cellIndexToAlbum(picModIndex!)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! AccountPictureCell
        cell.index = indexPath.row
        cell.delegate = self
        if indexPath.item < Me.user.picturesArr?.count && Me.user.picturesArr?[indexPath.item] != "null" {
        if let picURL = Me.user.picturesArr?[indexPath.item] {
            if let accountCellImg = imgCache.objectForKey(picURL){
                cell.setImg(accountCellImg as! UIImage)
            } else {
                DownloadImage.downloadImage(NSURL(string: picURL)!) {
                    img in
                    cell.setImg(img)
                    self.imgCache.setObject(img, forKey: picURL)
                }
            }
        }
        }

        
        cell.backgroundColor = UIColor.blueColor()
        return cell
    }
        
}