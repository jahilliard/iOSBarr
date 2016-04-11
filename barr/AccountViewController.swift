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
    
    @IBOutlet var photoCollection: UICollectionView!
    
    let imgCache: NSCache = NSCache()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true);
        photoCollection.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollection.dataSource = self
        photoCollection.delegate = self
        photoCollection.backgroundColor = UIColor.whiteColor()
        
        if let layout = photoCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        }
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
        return 3;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! AccountPictureCell
        cell.index = indexPath.row
        cell.delegate = self
        print(Me.user.picturesArr?[indexPath.item])
        if indexPath.item < Me.user.picturesArr?.count && Me.user.picturesArr?[indexPath.item] != "null" {
        if let picURL = Me.user.picturesArr?[indexPath.item] {
            if let accountCellImg = imgCache.objectForKey(picURL){
                cell.initialize(accountCellImg as! UIImage)
            } else {
                DownloadImage.downloadImage(NSURL(string: picURL)!) {
                    img in
                    print(img)
                    cell.initialize(img)
                }
            }
        }
        }
        cell.backgroundColor = UIColor.blueColor()
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! AccountPictureCell
        if (cell.delegate != nil) {
            cell.delegate!.preformSegue(cell)
        }
    }
    
}