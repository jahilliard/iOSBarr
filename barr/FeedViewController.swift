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
    
    @IBOutlet weak var feedTableView: UITableView!
    
    private var feedEntries : [FeedEntry] {
        get {
            return FeedManager.sharedInstance.feedEntries;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedViewController.updateEntries(_:)), name: newFeedEntriesNotification, object: nil);
        self.feedTableView.delegate = self;
        self.feedTableView.dataSource = self;
        
        //self.tableView.registerClass(FeedTableViewCell.self, forCellReuseIdentifier: "Cell")
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
                derived.initCell(feedEntry, reloadCellDelegate: self);
                break;
            
            case FeedEntry.FeedEntryEnum.VIDEO:
                cell  = tableView.dequeueReusableCellWithIdentifier("FeedTableViewVideoCell", forIndexPath: indexPath) as! FeedTableViewVideoCell;
                let derived : FeedTableViewVideoCell = cell as! FeedTableViewVideoCell;
                derived.initCell(feedEntry);
                break;
            
            case FeedEntry.FeedEntryEnum.TEXT:
                cell = tableView.dequeueReusableCellWithIdentifier("FeedTableViewTextCell", forIndexPath: indexPath) as! FeedTableViewTextCell;
                let derived : FeedTableViewTextCell = cell as! FeedTableViewTextCell;
                derived.initCell(feedEntry);
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
                let heightDifference = newImageHeight - oldImageHeight;
                height = oldHeight + heightDifference + (feedEntry.text.heightWithConstrainedWidth(textViewWidth, font: genericCell.postText.font!) - oldTextViewHeight);
                break;
                
            case FeedEntry.FeedEntryEnum.VIDEO:
                break;
                
            case FeedEntry.FeedEntryEnum.TEXT:
                let genericCell = cellHolder.textCellGeneric!;
                let oldHeight = genericCell.frame.height;
                let textViewWidth = genericCell.postText.frame.width;
                let oldTextViewHeight = genericCell.postText.frame.height;
                
                height = oldHeight + (feedEntry.text.heightWithConstrainedWidth(textViewWidth, font: genericCell.postText.font!) - oldTextViewHeight);
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
