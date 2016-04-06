//
//  FeedViewController.swift
//  barr
//
//  Created by Justin Hilliard on 3/31/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

protocol ReloadCellDelegate {
    func reloadCellWithEntryId(entryId: String)
}

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ReloadCellDelegate {
    let MAX_IMAGE_HEIGHT : CGFloat = 300.0;
    
    var numUnretrieved = 0;
    
    @IBOutlet weak var feedTableView: UITableView!
    
    private var feedEntries : [FeedEntry] {
        get {
            return FeedManager.sharedInstance.feedEntries;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedViewController.updateEntries(_:)), name: newFeedEntriesNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedViewController.clearEntries(_:)), name: clearFeedNotification, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedViewController.loadIfNecessary(_:)), name: loadIfNecessaryNotifictation, object: nil);
        self.feedTableView.delegate = self;
        self.feedTableView.dataSource = self;
        
        //self.tableView.registerClass(FeedTableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func loadIfNecessary(notification : NSNotification) {
        if let visibleIndexPaths = self.feedTableView.indexPathsForVisibleRows
        {
            if visibleIndexPaths.indexOf({$0.row == 0}) != nil {
                FeedManager.sharedInstance.getFeedEntries();
            }
        }
    }
    
    @objc func clearEntries(notification : NSNotification){
        self.feedTableView.reloadData();
    }
    
    @objc func updateEntries(notification : NSNotification){
        if let updateInfo = notification.userInfo as? Dictionary<String, AnyObject>, updatedEntryIndexes = updateInfo["updatedEntryIndexes"] as? [Int]
        {
            var updateArray = [NSIndexPath]();
            for entry in updatedEntryIndexes {
                updateArray.append(NSIndexPath(forRow: entry, inSection: 0));
            }
            
            self.feedTableView.beginUpdates();
            self.feedTableView.insertRowsAtIndexPaths(updateArray, withRowAnimation: .Automatic)
            self.feedTableView.endUpdates();
            
        } else {
            return;
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return feedEntries.count;
    }
    
    var cell : UITableViewCell!;
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let feedEntry = self.feedEntries[indexPath.row];
        
        switch feedEntry.type {
            case FeedEntry.FeedEntryEnum.IMAGE:
                cell = tableView.dequeueReusableCellWithIdentifier("FeedTableViewImageCell", forIndexPath: indexPath) as! FeedTableViewImageCell;
                let derived : FeedTableViewImageCell = cell as! FeedTableViewImageCell;
                derived.clearCell();
                derived.initCell(feedEntry, reloadCellDelegate: self);
                
                if indexPath.row == 0 && !FeedManager.sharedInstance.retrievingEntries && FeedManager.sharedInstance.numNewEntries > 0
                {
                    FeedManager.sharedInstance.getFeedEntries();
                }
                
                //set profile picture
                if feedEntry.authorInfo.pictures.count > 0 {
                    Circle.getProfilePictureByURL(feedEntry.authorInfo.pictures[0], completion: {profileImg in
                        dispatch_async(dispatch_get_main_queue(), {
                            //check same cell hasnt been reused
                            if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? FeedTableViewImageCell where cellToUpdate.entryInfo.entryId == feedEntry.entryId {
                                cellToUpdate.userImg.image = profileImg;
                            }
                        });
                    });
                } else {
                    derived.userImg.image = UIImage(imageLiteral: "defaultProfilePicture.jpg");
                }
                
                //set main body image
                if let img = feedEntry.mainImage {
                    derived.mainImage.image = img;
                } else {
                    AlamoHelper.getFeedMedia(feedEntry.entryId, callback: {(err, data) in
                        if err != nil || data == nil{
                            //TODO: notify user on screen of connection/get error
                            return;
                        } else {
                            if let image = UIImage(data: data!) {
                                feedEntry.mainImage = image;
                                feedEntry.imageHeight = image.size.height;
                                dispatch_async(dispatch_get_main_queue(), {
                                    //check same cell hasnt been reused
                                    if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? FeedTableViewImageCell where cellToUpdate.entryInfo.entryId == feedEntry.entryId {
                                        cellToUpdate.mainImage.image = image;
                                        self.reloadCellWithEntryId(feedEntry.entryId);
                                    }
                                });
                            } else {
                                //TODO: handle bad image
                            }
                        }
                    });
                }
                
                break;
            
            case FeedEntry.FeedEntryEnum.VIDEO:
                cell  = tableView.dequeueReusableCellWithIdentifier("FeedTableViewVideoCell", forIndexPath: indexPath) as! FeedTableViewVideoCell;
                let derived : FeedTableViewVideoCell = cell as! FeedTableViewVideoCell;
                derived.initCell(feedEntry);
                break;
            
            case FeedEntry.FeedEntryEnum.TEXT:
                cell = tableView.dequeueReusableCellWithIdentifier("FeedTableViewTextCell", forIndexPath: indexPath) as! FeedTableViewTextCell;
                let derived : FeedTableViewTextCell = cell as! FeedTableViewTextCell;
                derived.clearCell();
                derived.initCell(feedEntry);
                
                //set profile picture
                if feedEntry.authorInfo.pictures.count > 0 {
                    Circle.getProfilePictureByURL(feedEntry.authorInfo.pictures[0], completion: {profileImg in
                        dispatch_async(dispatch_get_main_queue(), {
                            //check same cell hasnt been reused
                            if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? FeedTableViewTextCell where cellToUpdate.entryInfo.entryId == feedEntry.entryId {
                                cellToUpdate.userImg.image = profileImg;
                            }
                        });
                    });
                } else {
                    derived.userImg.image = UIImage(imageLiteral: "defaultProfilePicture.jpg");
                }
                
                break;
        }
        
        // Configure the cell...
        
        return cell;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        struct cellHolder {
            static var imageCellGeneric : FeedTableViewImageCell? = nil;
            static var videoCellGeneric : FeedTableViewVideoCell? = nil;
            static var textCellGeneric : FeedTableViewTextCell? = nil;
        }
        
        if (cellHolder.imageCellGeneric == nil) {
            cellHolder.imageCellGeneric = tableView.dequeueReusableCellWithIdentifier("FeedTableViewImageCell") as! FeedTableViewImageCell;
        }
        
        if (cellHolder.videoCellGeneric == nil) {
            cellHolder.videoCellGeneric = tableView.dequeueReusableCellWithIdentifier("FeedTableViewVideoCell") as! FeedTableViewVideoCell;
        }
        
        if (cellHolder.textCellGeneric == nil) {
            cellHolder.textCellGeneric = tableView.dequeueReusableCellWithIdentifier("FeedTableViewTextCell") as! FeedTableViewTextCell;
        }
        
        let feedEntry = self.feedEntries[indexPath.row];
        var height : CGFloat = 0;
        
        switch feedEntry.type {
            case FeedEntry.FeedEntryEnum.IMAGE:
                let genericCell = cellHolder.imageCellGeneric!;
                let oldHeight = genericCell.frame.height;
                let textViewWidth = genericCell.postText.frame.width;
                let oldTextViewHeight = genericCell.postText.frame.height;
                let oldImageHeight = genericCell.mainImage.frame.height;
                let newImageHeight = min(feedEntry.imageHeight, MAX_IMAGE_HEIGHT);
                let imageHeightDifference = newImageHeight - oldImageHeight;
                
                genericCell.postText.text = feedEntry.text;
                let newTextSize : CGSize = genericCell.postText.sizeThatFits(CGSize(width: textViewWidth, height: CGFloat.max));
                let newTextViewHeight = newTextSize.height;
                
                height = oldHeight + imageHeightDifference + (newTextViewHeight - oldTextViewHeight);
                break;
                
            case FeedEntry.FeedEntryEnum.VIDEO:
                break;
                
            case FeedEntry.FeedEntryEnum.TEXT:
                let genericCell = cellHolder.textCellGeneric!;
                let oldHeight = genericCell.frame.height;
                let textViewWidth = genericCell.postText.frame.width;
                let oldTextViewHeight = genericCell.postText.frame.height;
                
                //calculate size for text
                genericCell.postText.text = feedEntry.text;
                let newTextSize : CGSize = genericCell.postText.sizeThatFits(CGSize(width: textViewWidth, height: CGFloat.max));
                let newTextViewHeight = newTextSize.height;
                
                height = oldHeight + (newTextViewHeight - oldTextViewHeight);
                break;
        }
        return height;
    }
    
    func reloadCellWithEntryId(entryId: String) {
        let index = self.feedEntries.indexOf({$0.entryId == entryId})!;
        let indexPath = [NSIndexPath(forRow: index, inSection: 0)];
        self.feedTableView.reloadRowsAtIndexPaths(indexPath, withRowAnimation: UITableViewRowAnimation.Automatic);
    }
    
    //        override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    //
    //        }
    
}
