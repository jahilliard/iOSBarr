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

class FeedManager {
    let RETRIEVE_AMOUNT = 50;
    static let sharedInstance : FeedManager = FeedManager();
    
    var feedEntries : [FeedEntry] = [];
    var seenEntries: [String: Bool] = [String: Bool]();
    var feedAuthorInfo : [String: UserInfo] = [String: UserInfo]();
    
    func restartFeed() {
        self.feedEntries = [];
        self.seenEntries = [String: Bool]();
        self.feedAuthorInfo = [String: UserInfo]();
        
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
                if oldEntry.date.timeIntervalSince1970 > newEntry.date.timeIntervalSince1970 {
                    continue;
                } else {
                    insertIndex = index;
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
                let newEntry = FeedEntry(authorInfo: authorInfo, entryId: entryId, type: entryType, text: text, date: date);
                
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
    
    func getLatestFeedEntries() {
        var params = [String: AnyObject]();
        params["numEntriesToFetch"] = RETRIEVE_AMOUNT;
        AlamoHelper.authorizedGet("api/v1/feed/\(Circle.sharedInstance.circleId)/latest", parameters: params, completion: {(err, resp) in
            if (err != nil) {
                //TODO: handle error
                self.getLatestFeedEntries();
            } else {
                //TODO: handle error
                if resp!["message"].string != "success" {
                    self.getLatestFeedEntries();
                } else {
                    self.processFeedEntryAuthors(resp!["entryAuthors"]);
                    self.processLatestFeedEntries(resp!["entries"]);
                }
            }
        });
    }
    
    private init(){}
}
    