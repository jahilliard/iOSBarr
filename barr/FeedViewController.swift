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

protocol DisplayPictureDelegate {
    func displayImage(image: UIImage);
}

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ReloadCellDelegate, UIScrollViewDelegate, DisplayPictureDelegate {
    
    @IBOutlet weak var postFeedBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var postFeedBar: UIView!
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var yourTabPicture: UIImageView!
    @IBAction func IBOutletvaronNewFeedEntryTappedUITapGestureRecognizer(sender: AnyObject) {
        self.performSegueWithIdentifier("toNewFeedEntry", sender: self);
    }
    
    let MAX_IMAGE_HEIGHT : CGFloat = 300.0;
    
    var lastOffsetCapture: NSTimeInterval! = nil;
    var lastOffset: CGPoint! = nil;
    var dragStart: CGFloat! = nil;
    var originalHeight : CGFloat! = nil;
    
    let minOffsetToTriggerRefresh : CGFloat = 100;
    
    var numUnretrieved = 0;

    private var feedEntries : [FeedEntry] {
        get {
            return FeedManager.sharedInstance.feedEntries;
        }
    }
    
    override func viewDidLayoutSubviews() {
        print(self.postFeedBarTopConstraint.constant);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedViewController.updateEntries(_:)), name: newFeedEntriesNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedViewController.clearEntries(_:)), name: clearFeedNotification, object: nil);
        
        self.originalHeight = self.postFeedBarTopConstraint.constant;
        /*NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedViewController.loadIfNecessary(_:)), name: loadIfNecessaryNotifictation, object: nil);*/
        self.feedTableView.delegate = self;
        self.feedTableView.dataSource = self;
        if let imagesArr = Me.user.picturesArr where imagesArr.count > 0 {
            Circle.getProfilePictureByURL(imagesArr[0], completion: {img in self.yourTabPicture.image = img});
        } else {
            self.yourTabPicture.image = UIImage(imageLiteral: "defaultProfilePicture.jpg");
        }
        
        //self.tableView.registerClass(FeedTableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    /*func loadIfNecessary(notification : NSNotification) {
        if let visibleIndexPaths = self.feedTableView.indexPathsForVisibleRows
        {
            if visibleIndexPaths.indexOf({$0.row == 0}) != nil {
                FeedManager.sharedInstance.getFeedEntries();
            }
        }
    }*/
    
    @objc func clearEntries(notification : NSNotification){
        self.feedTableView.reloadData();
    }
    
    @objc func updateEntries(notification : NSNotification){
        if let updateInfo = notification.userInfo as? Dictionary<String, AnyObject>, updatedEntryIndexes = updateInfo["updatedEntryIndexes"] as? [Int]
        {
            var updateArray = [NSIndexPath]();
            //var heightForNewRows : CGFloat = 0;
            for entry in updatedEntryIndexes {
                let tempIndexPath = NSIndexPath(forRow: entry, inSection: 0);
                updateArray.append(tempIndexPath);
                //heightForNewRows += self.heightForRowAtIndexPath(tempIndexPath);
            }
            
            //var beforeContentSize = self.feedTableView.contentOffset;
            //let beforeContentSize = self.feedTableView.contentSize;
            self.feedTableView.beginUpdates();
            self.feedTableView.insertRowsAtIndexPaths(updateArray, withRowAnimation: .Fade);
            //beforeContentSize.y += heightForNewRows;
            //self.feedTableView.setContentOffset(beforeContentSize, animated: false);
            self.feedTableView.endUpdates();
            
            /*self.feedTableView.reloadData();
            
            let afterContentSize = self.feedTableView.contentSize;
            let afterContentOffset = self.feedTableView.contentOffset;
            let newContentOffset = CGPointMake(afterContentOffset.x, afterContentOffset.y + afterContentSize.height - beforeContentSize.height);
            self.feedTableView.contentOffset = newContentOffset;*/
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
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,forRowAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.row == self.feedEntries.count - 1 && FeedManager.sharedInstance.numOldEntries > 0
        {
            FeedManager.sharedInstance.getOlderEntries();
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let feedEntry = self.feedEntries[indexPath.row];
        var cell : UITableViewCell!;
        switch feedEntry.type {
            case FeedEntry.FeedEntryEnum.IMAGE:
                cell = tableView.dequeueReusableCellWithIdentifier("FeedTableViewImageCell", forIndexPath: indexPath) as! FeedTableViewImageCell;
                let derived : FeedTableViewImageCell = cell as! FeedTableViewImageCell;
                derived.clearCell();
                derived.initCell(feedEntry, displayPictureDelegate: self);
                
                /*if indexPath.row == 0 && FeedManager.sharedInstance.numNewEntries > 0
                {
                    FeedManager.sharedInstance.getFeedEntries();
                }*/
                
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
                if let mainImage = FeedManager.sharedInstance.imgCache.objectForKey(feedEntry.entryId) as? UIImage {
                    derived.mainImage.image = mainImage;
                } else {
                    AlamoHelper.getFeedMedia(feedEntry.entryId, callback: {(err, data) in
                        if err != nil || data == nil{
                            //TODO: notify user on screen of connection/get error
                            return;
                        } else {
                            if let image = UIImage(data: data!) {
                                feedEntry.imageHeight = image.size.height;
                                dispatch_async(dispatch_get_main_queue(), {
                                    //check same cell hasnt been reused
                                    if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? FeedTableViewImageCell where cellToUpdate.entryInfo.entryId == feedEntry.entryId {
                                        FeedManager.sharedInstance.imgCache.setObject(image, forKey: feedEntry.entryId)
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
            
            if let mainImage = FeedManager.sharedInstance.imgCache.objectForKey(feedEntry.entryId) as? UIImage {
                feedEntry.imageHeight = mainImage.size.height;
            }
            
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

            let colorArr = [UIColor(red: 212, green: 22, blue: 28),UIColor(red: 133, green: 210, blue: 224), UIColor(red: 42, green: 162, blue: 140), UIColor(red: 222, green: 32, blue: 110), UIColor(red: 236, green: 180, blue: 65),UIColor(red: 79, green: 193, blue: 158), UIColor(red: 62, green: 19, blue: 61)]
            
            let topDiv = UIView(frame: CGRect(origin: CGPoint(x: 0, y:  genericCell.frame.height-1), size: CGSize(width: genericCell.frame.width, height: 1)))
            topDiv.backgroundColor = colorArr[indexPath.row%colorArr.count]
            genericCell.addSubview(topDiv);
            
            // Configure the cell...
            height = oldHeight + (newTextViewHeight - oldTextViewHeight);
            break;
        }
        return height;
    }

    func heightForRowAtIndexPath(indexPath: NSIndexPath) -> CGFloat {
        struct cellHolder {
            static var imageCellGeneric : FeedTableViewImageCell? = nil;
            static var videoCellGeneric : FeedTableViewVideoCell? = nil;
            static var textCellGeneric : FeedTableViewTextCell? = nil;
        }
        
        if (cellHolder.imageCellGeneric == nil) {
            cellHolder.imageCellGeneric = self.feedTableView.dequeueReusableCellWithIdentifier("FeedTableViewImageCell") as! FeedTableViewImageCell;
        }
        
        if (cellHolder.videoCellGeneric == nil) {
            cellHolder.videoCellGeneric = self.feedTableView.dequeueReusableCellWithIdentifier("FeedTableViewVideoCell") as! FeedTableViewVideoCell;
        }
        
        if (cellHolder.textCellGeneric == nil) {
            cellHolder.textCellGeneric = self.feedTableView.dequeueReusableCellWithIdentifier("FeedTableViewTextCell") as! FeedTableViewTextCell;
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "toNewFeedEntry") {
            let newFeedEntryViewController = segue.destinationViewController as! UINavigationController;
            newFeedEntryViewController.hidesBottomBarWhenPushed = true;
        }
        
        else if (segue.identifier == "toMainImage") {
            if let img = sender as? UIImage {
                let displayImageController = segue.destinationViewController as! DisplayFeedImageViewController;
                displayImageController.mainImage = img;
                displayImageController.hidesBottomBarWhenPushed = true;
            }
        }
    }
    
    func displayImage(image: UIImage) {
        self.performSegueWithIdentifier("toMainImage", sender: image);
    }
    
    func reloadCellWithEntryId(entryId: String) {
        let index = self.feedEntries.indexOf({$0.entryId == entryId})!;
        let indexPath = [NSIndexPath(forRow: index, inSection: 0)];
        self.feedTableView.reloadRowsAtIndexPaths(indexPath, withRowAnimation: UITableViewRowAnimation.Automatic);
    }
    
    @IBAction func cancelToFeedViewController(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func postNewFeedEntry(segue: UIStoryboardSegue) {
        if let newFeedEntryViewController = segue.sourceViewController as? NewFeedEntryViewController
        {
            var image : UIImage? = nil;
            
            var params = [String: AnyObject]();
            if let text = newFeedEntryViewController.text {
                params["text"] = text;
            } else {
                params["text"] = "";
            }
            if let img = newFeedEntryViewController.selectedImage {
                image = img;
            }
            
            AlamoHelper.postNewFeedEntry(image, params: params, completion: {(err, resp) in
                if err != nil || resp!["message"] != "success" {
                    //TODO: handle
                } else {
                    
                }})
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.dragStart = scrollView.contentOffset.y;
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            return;
        }
        
        let currentOffset : CGPoint = scrollView.contentOffset;
        let currentTime = NSDate.timeIntervalSinceReferenceDate();
        
        if self.lastOffset == nil {
            self.lastOffset = currentOffset;
        }
        
        if self.lastOffsetCapture == nil {
            self.lastOffsetCapture = currentTime;
        }
        
        
        let timeDiff : NSTimeInterval = currentTime - lastOffsetCapture;
        
        /*if(timeDiff > 0.1) {
            let distance = currentOffset.y - lastOffset.y;
            self.lastOffset = currentOffset;
            self.lastOffsetCapture = currentTime;
            
            //self.postFeedBar.frame.origin.y -= distance;
            let minY = self.originalHeight - self.postFeedBar.frame.height;
            //print(self.postFeedBar.frame.origin.y);
            if self.postFeedBar.frame.origin.y < minY {
                self.postFeedBar.frame.origin.y = minY;
            }
            
            else if self.postFeedBar.frame.origin.y > self.originalHeight {
                self.postFeedBar.frame.origin.y = self.originalHeight;
            }
        }*/
        
        if(timeDiff > 0.1) {
            let distance = currentOffset.y - lastOffset.y;
            self.lastOffset = currentOffset;
            self.lastOffsetCapture = currentTime;
            
            self.postFeedBarTopConstraint.constant -= distance;
            
            //print(self.postFeedBar.frame.origin.y);
            if self.postFeedBarTopConstraint.constant < -self.postFeedBar.frame.size.height {
                self.postFeedBarTopConstraint.constant = -self.postFeedBar.frame.size.height;
            }
                
            else if self.postFeedBarTopConstraint.constant > originalHeight {
                self.postFeedBarTopConstraint.constant = originalHeight;
            }
            
            
            self.postFeedBar.alpha = self.calculatePostFeedBarAlpha();
            self.view.layoutIfNeeded();
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        if (self.dragStart == nil) {
            return;
        }
        
        let dragDistance = self.dragStart - scrollView.contentOffset.y;
        var heightConstraint : CGFloat? = nil;
        
        if decelerate {
            if dragDistance > 0 {
                //self.postFeedBar.frame.origin.y = self.originalHeight;
                heightConstraint = self.originalHeight;

            }
            
            if dragDistance < 0 {
                /*let minY = self.originalHeight - self.postFeedBar.frame.height;
                self.postFeedBar.frame.origin.y = minY;*/
                heightConstraint = -self.postFeedBar.frame.size.height;            }
        } else {
            if dragDistance < self.postFeedBar.frame.size.height && dragDistance > 0 {
                /*self.postFeedBar.frame.origin.y = self.originalHeight - self.postFeedBar.frame.size.height;*/
                heightConstraint = -self.postFeedBar.frame.size.height;
            }
            
            if dragDistance > -self.postFeedBar.frame.size.height && dragDistance < 0 {
                /*self.postFeedBar.frame.origin.y = self.originalHeight;
                print(self.postFeedBar.frame.origin.y);*/
                heightConstraint = self.originalHeight;
            }
        }
        
        
        if heightConstraint != nil {
            self.postFeedBarTopConstraint.constant = heightConstraint!;
            self.postFeedBar.alpha = self.calculatePostFeedBarAlpha();
            self.view.layoutIfNeeded();
        }
        
        if scrollView.contentOffset.y <= -minOffsetToTriggerRefresh {
            FeedManager.sharedInstance.getFeedEntries();
        }
    }
    
    func calculatePostFeedBarAlpha() -> CGFloat{
        let maxDifference = self.postFeedBar.frame.height;
        let difference = self.originalHeight - self.postFeedBarTopConstraint.constant;
        let differenceRatio = difference/maxDifference;
        return 1 - differenceRatio;
    }
    
    //        override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    //
    //        }
    
}
