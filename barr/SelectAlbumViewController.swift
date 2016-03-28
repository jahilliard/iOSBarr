//
//  SelectAlbumViewController.swift
//  barr
//
//  Created by Justin Hilliard on 3/23/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import SwiftyJSON

protocol InfoToPhotoDelegate {
    func sendAlbumAndIndexInfo(isUserPhotos: Bool, albumName: String, albumId: String, index: Int)
}

class SelectAlbumViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, cellIndexToAlbumDelegate {
    
    var delegate: InfoToPhotoDelegate?
    
    var fbAlbums: [JSON] = [JSON(["id": Me.user.userId!, "name": "My Photos"])]
    var tableView: UITableView = UITableView()
    
    var indexToMod: Int?
    
    var isUserPhotos: Bool?
    var albumName: String?
    var albumId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getFbAlbums()
        
        tableView = UITableView(frame: CGRect(origin: CGPoint(x: 0, y: self.navigationController!.navigationBar.frame.size.height), size: CGSize(width: screenSize.width, height: screenSize.height - self.tabBarController!.tabBar.frame.size.height)))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.greenColor()
        self.view.addSubview(tableView)
    }
    
    func getFbAlbums(){
        let req = FBSDKGraphRequest(graphPath: Me.user.fbId! + "/albums", parameters: nil, tokenString: Me.user.fbAuthtoken!, version: nil, HTTPMethod: "GET")
        req.startWithCompletionHandler({
            (connection, result, error) -> Void in
            
            if error != nil {
                print("error with Graph req")
            }
            
            let itterItems = JSON(result)["data"].arrayValue
            for item in itterItems {
                self.fbAlbums.append(item)
            }
            self.tableView.reloadData()
        })
    }
    
    func cellIndexToAlbum(index: Int) {
        indexToMod = index
    }
    
    //MARK: - Tableview Delegate & Datasource
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        return self.fbAlbums.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = self.fbAlbums[indexPath.row]["name"].rawString()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            isUserPhotos = true
        } else {
            isUserPhotos = false
        }
        albumName =  self.fbAlbums[indexPath.row]["name"].rawString()
        albumId =   self.fbAlbums[indexPath.row]["id"].rawString()
        self.performSegueWithIdentifier("selectPhoto", sender: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "selectPhoto") {
            let selectAlb: SelectPhotosViewController = segue.destinationViewController as! SelectPhotosViewController
            delegate = selectAlb
            if delegate != nil {
                delegate!.sendAlbumAndIndexInfo(isUserPhotos!, albumName: albumName!, albumId: albumId!, index: indexToMod!)
            }
        }
    }
    
    

}

