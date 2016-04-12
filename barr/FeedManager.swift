//
//  FeedManager.swift
//  barr
//
//  Created by Carl Lin on 4/2/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import Foundation

import Foundation
import Alamofire
import SwiftyJSON

let newFeedEntriesNotification = "barr.app.newFeedEntriesNotification";
let clearFeedNotification = "barr.app.clearFeedEntriesNotification";
//let loadIfNecessaryNotifictation = "barr.app.loadIfNecessaryNotifictation";

class FeedManager {
    let RETRIEVE_AMOUNT = 3;
    //in seconds
    let RETRIEVE_INTERVAL : Double = 3;
    
    static let sharedInstance : FeedManager = FeedManager();
    
    var feedEntries : [FeedEntry] = [];
    var seenEntries: [String: Bool] = [String: Bool]();
    var feedAuthorInfo : [String: UserInfo] = [String: UserInfo]();
    //var numNewEntries: Int = 0;
    var numOldEntries: Int = 0;
    var imgCache: NSCache = NSCache();
    
    //make sure only one retrieval/processing of retrieval is happening at a time
    var retrievingNewEntries : Bool = false;
    var retrievingOldEntries : Bool = false;
    //make sure callback returns before getting more updates
    var retrievingNumUpdates : Bool = false;
    
    func restartFeed() {
        self.feedEntries = [];
        self.seenEntries = [String: Bool]();
        self.feedAuthorInfo = [String: UserInfo]();
        //self.numNewEntries = 0;
        NSNotificationCenter.defaultCenter().postNotificationName(clearFeedNotification, object: self, userInfo: nil);
    }
    
    func notifyFeed(updatedEntryIndexes: [Int]) {
        NSNotificationCenter.defaultCenter().postNotificationName(newFeedEntriesNotification, object: self, userInfo: ["updatedEntryIndexes": updatedEntryIndexes]);
    }
    
    func processFeedEntryAuthors(authors: JSON) {
        print(authors);
        for author in authors.arrayValue {
            self.addAuthor(author);
        }
    }
    
    func startFeedPolling() {
        _ = NSTimer.scheduledTimerWithTimeInterval(RETRIEVE_INTERVAL, target: self, selector: #selector(FeedManager.retrieveNumUpdates), userInfo: nil, repeats: true);
    }
    
    func addAuthor(author: JSON) {
        //TODO: hacky way to get around userinfo initiation
        var authorCopy = author;
        authorCopy["lastMsgNum"] = JSON(0);
        if let authorInfo = UserInfo(userInfo: authorCopy) {
            self.feedAuthorInfo[authorInfo.userId] = authorInfo;
        }
    }
    
    func addNewEntry(newEntry: FeedEntry) -> Bool {
        //already got this before
        if ((self.seenEntries[newEntry.entryId]) != nil) {
            return false;
        } else {
            self.seenEntries[newEntry.entryId] = true;
            //find where to insert
            var insertIndex = 0;
            for (index, oldEntry) in feedEntries.enumerate() {
                if newEntry.date.timeIntervalSince1970 > oldEntry.date.timeIntervalSince1970 {
                    insertIndex = index;
                    break;
                } else {
                    insertIndex+=1;
                }
            }
            
            feedEntries.insert(newEntry, atIndex: insertIndex);
            return true;
        }
    }
    
    func processLatestFeedEntries(entries: JSON){
        print(entries);
        var addedEntries = [String]();
        
        for entry in entries.arrayValue {
            if let authorId = entry["userId"].string, authorInfo = self.feedAuthorInfo[authorId], entryId = entry["_id"].string, text = entry["text"].string, entryTypeInt = entry["entryType"].int, entryType = FeedEntry.FeedEntryEnum(rawValue: entryTypeInt), dateString = entry["date"].string, date = Helper.dateFromString(dateString)
            {
                let newEntry = FeedEntry(authorInfo: authorInfo, entryId: entryId, type: entryType, text: text, dateString: dateString, date: date);
                
                //only add new entry if we haven't seen an entry with this id before
                if self.addNewEntry(newEntry) {
                    addedEntries.append(entryId);
                }
            }
        }
        
        var updateInfo = [Int]();
        
        for entryId in addedEntries {
            let index = self.feedEntries.indexOf({$0.entryId == entryId})!;
            updateInfo.append(index);
        }
        
        if addedEntries.count > 0 {
            notifyFeed(updateInfo);
        }
    }
    
    @objc func retrieveNumUpdates(){
        if (self.retrievingNumUpdates) {
            return;
        }
        var params : [String: AnyObject] = [String: AnyObject]();
        if self.feedEntries.count > 0 {
            params["latestDate"] = self.feedEntries[0].dateString;
        }
        self.retrievingNumUpdates = true;
        AlamoHelper.authorizedGet("api/v1/feed/\(Circle.sharedInstance.circleId)/numUpdates", parameters: params, completion: {(err, resp) in
            if (err != nil) {
                self.retrievingNumUpdates = false;
                return;
            }
            
            if let latestDateString = resp!["latestDate"].string, numNewEntries = resp!["numNewEntries"].int where numNewEntries > 0
            {
                //check no updates have happened in between
                
                if (latestDateString == "null" && self.feedEntries.count == 0) ||
                    ((self.feedEntries.count > 0) && (latestDateString == self.feedEntries[0].dateString))
                {
                    //self.numNewEntries = numNewEntries;
                    /*NSNotificationCenter.defaultCenter().postNotificationName(loadIfNecessaryNotifictation, object: self, userInfo: nil);*/
                }
            }
            
            self.retrievingNumUpdates = false;
        })
    }
    
    func getFeedEntries() {
        if FeedManager.sharedInstance.retrievingNewEntries /*|| FeedManager.sharedInstance.numNewEntries == 0*/ {
            return;
        }
        
        var params = [String: AnyObject]();
        params["numEntriesToFetch"] = RETRIEVE_AMOUNT; //min(numNewEntries, RETRIEVE_AMOUNT);
        if self.feedEntries.count > 0 {
            params["earliestDate"] = feedEntries[0].dateString;
        }
        
        self.retrievingNewEntries = true;
        AlamoHelper.authorizedGet("api/v1/feed/\(Circle.sharedInstance.circleId)/updates", parameters: params, completion: {(err, resp) in
            if err != nil || resp!["message"].string != "success" {
                self.retrievingNewEntries = false;
                return;
            }
            
            print(resp!["entries"].arrayValue.count);
            if resp!["entries"].arrayValue.count == 0 {
                self.retrievingNewEntries = false;
                return;
            }
            
            if let numUnretrieved = resp!["numUnretrieved"].int {
                self.processFeedEntryAuthors(resp!["entryAuthors"]);
                self.processLatestFeedEntries(resp!["entries"]);
                //self.numNewEntries = numUnretrieved;
            }
            self.retrievingNewEntries = false;
        });
    }
    
    func getOlderEntries() {
        if FeedManager.sharedInstance.retrievingOldEntries || FeedManager.sharedInstance.numOldEntries == 0 || self.feedEntries.count <= 0
        {
            return;
        }
        
        var params = [String: AnyObject]();
        params["numEntriesToFetch"] = min(numOldEntries, RETRIEVE_AMOUNT);
        params["latestDate"] = self.feedEntries[self.feedEntries.count - 1].dateString;
        
        self.retrievingOldEntries = true;
        AlamoHelper.authorizedGet("api/v1/feed/\(Circle.sharedInstance.circleId)/older", parameters: params, completion: {(err, resp) in
            if err != nil || resp!["message"].string != "success" {
                self.retrievingOldEntries = false;
                return;
            }
            
            print(resp!["entries"].arrayValue.count);
            if resp!["entries"].arrayValue.count == 0 {
                self.retrievingOldEntries = false;
                return;
            }
            
            if let numUnretrieved = resp!["numUnretrieved"].int {
                self.processFeedEntryAuthors(resp!["entryAuthors"]);
                self.processLatestFeedEntries(resp!["entries"]);
                self.numOldEntries = numUnretrieved;
            }
            self.retrievingOldEntries = false;
        });
    }
    
    //only calld once on initialization
    func getLatestFeedEntries() {
        var params = [String: AnyObject]();
        params["numEntriesToFetch"] = RETRIEVE_AMOUNT;
        self.retrievingNewEntries = true;
        AlamoHelper.authorizedGet("api/v1/feed/\(Circle.sharedInstance.circleId)/latest", parameters: params, completion: {(err, resp) in
            if (err != nil) {
                //TODO: handle error
                self.getLatestFeedEntries();
            } else {
                //TODO: handle error
                if resp!["message"].string != "success" {
                    self.getLatestFeedEntries();
                } else {
                    if let numOldEntries = resp!["numRemainingEntries"].int where resp!["entryAuthors"] != nil && resp!["entries"] != nil
                    {
                        self.processFeedEntryAuthors(resp!["entryAuthors"]);
                        self.processLatestFeedEntries(resp!["entries"]);
                        self.retrievingNewEntries = false;
                        self.numOldEntries = numOldEntries;
                        //FeedManager.sharedInstance.startFeedPolling();
                    }
                }
            }
        });
    }
    
    private init(){}
}
    