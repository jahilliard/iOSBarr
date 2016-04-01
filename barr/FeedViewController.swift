//
//  FeedViewController.swift
//  barr
//
//  Created by Justin Hilliard on 3/31/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

class FeedViewController: UITableViewController {
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.tableView.registerClass(FeedTableViewCell.self, forCellReuseIdentifier: "Cell")
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
        
        // MARK: - Table view data source
        
        override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            // #warning Incomplete implementation, return the number of sections
            return 1;
        }
        
        override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // #warning Incomplete implementation, return the number of rows
            return 2;
        }
        
        override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FeedTableViewCell;
            
            // Configure the cell...
            
            return cell;
        }
        
//        override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//            
//        }
    
}
