//
//  ChatListViewController.swift
//  barr
//
//  Created by Carl Lin on 3/4/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

class ChatListViewController: UITableViewController {
    var selectedChateeId: String = "";
    var chatOrder: [String] = [String]();
    
    func updateChatOrder(){
        let chateeIds = Array(ChatManager.sharedInstance.chats.keys);
        self.chatOrder = self.sortChateeIds(chateeIds);
    }
    
    func sortChateeIds(chateeIds: [String]) -> [String] {
        return chateeIds.sort({ChatManager.sharedInstance.getChat($0)!.lastUpdate.timeIntervalSince1970 > ChatManager.sharedInstance.getChat($1)!.lastUpdate.timeIntervalSince1970})
    }
    
    func updateList(notification : NSNotification){
        print("updateList Called");
        self.updateChatOrder();
        self.tableView.reloadData();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateChatOrder();
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    /* TODO: 
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }*/
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatListViewController.updateList(_:)), name: ChatManager.sharedInstance.chatListNotification, object: nil);
        self.tableView.reloadData();
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self);
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
        return self.chatOrder.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatListTableViewCell", forIndexPath: indexPath) as! ChatListTableViewCell;
        
        // Configure the cell...
        let chatOrder = self.chatOrder;
        let chateeId = chatOrder[indexPath.row];
        cell.initialize(chateeId);
        return cell;
    }
    
    /*override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let tHeight = tableView.bounds.height
        
        return tHeight/5;
    }*/
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedChateeId = self.chatOrder[indexPath.row];
        self.selectedChateeId = selectedChateeId;
        
        if (ChatManager.sharedInstance.getChat(selectedChateeId)!.containsUnread){
            ChatManager.sharedInstance.getChat(selectedChateeId)!.containsUnread = false;
            
            //TODO: this animation unnecessary if table view rerenders on coming back from the segue
            self.tableView.beginUpdates()
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None);
            self.tableView.endUpdates();
        }
        
        performSegueWithIdentifier("toChat", sender: self)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toChat"{
            let chatViewController = segue.destinationViewController as! ChatViewController;
            chatViewController.otherUserInfo = ChatManager.sharedInstance.getChat(selectedChateeId)!.chatee;
            chatViewController.hidesBottomBarWhenPushed = true;
        }
    }
}
