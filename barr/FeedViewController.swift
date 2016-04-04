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
            return 10;
        }
        
        override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FeedTableViewCell;
            
            let colorArr = [UIColor(red: 212, green: 22, blue: 28),UIColor(red: 133, green: 210, blue: 224), UIColor(red: 42, green: 162, blue: 140), UIColor(red: 222, green: 32, blue: 110), UIColor(red: 236, green: 180, blue: 65),UIColor(red: 79, green: 193, blue: 158), UIColor(red: 62, green: 19, blue: 61)]
            
            let topDiv = UIView(frame: CGRect(origin: CGPoint(x: 0, y:  cell.frame.height-1), size: CGSize(width: cell.frame.width, height: 1)))
            topDiv.backgroundColor = colorArr[indexPath.row%colorArr.count]
            cell.addSubview(topDiv)
            
            // Configure the cell...
            
            return cell;
        }
        
//        override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//            
//        }
    
}
