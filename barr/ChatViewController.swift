//
//  ChatViewController.swift
//  barr
//
//  Created by Carl Lin on 3/1/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
    UITextFieldDelegate
{
    @IBOutlet weak var sendMsgButton: UIButton!
    @IBOutlet weak var messageInputField: UITextField!
    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet weak var dockViewHeightConstraint: NSLayoutConstraint!
    var otherUserId : String! {
        didSet {
            self.title = self.otherUserId;
        }
    }
    
    
    @IBAction func OnButtonClick(sender: UIButton)
    {
        if let text : String = self.messageInputField.text {
            ChatManager.sharedInstance.sendMessage(self.otherUserId, message: text);
            self.messageInputField.text = "";
        }
        
        self.messageInputField.endEditing(true);
    }
    
    private var chatMessages : [Message] {
        get {
            let chat = ChatManager.sharedInstance.getChat(self.otherUserId);
            if (chat != nil) {
                return chat!.messages;
            } else {
                return [];
            }
        }
    }
    
    func appendNewMessage(){
        self.messagesTableView.beginUpdates()
        self.messagesTableView.insertRowsAtIndexPaths([
            NSIndexPath(forRow: self.chatMessages.count-1, inSection: 0)
            ], withRowAnimation: .Automatic)
        self.messagesTableView.endUpdates()
    }
    
    @objc func checkNewMessage(notification : NSNotification){
        if let info = notification.userInfo as? Dictionary<String,String> {
            if let chateeId = info["chateeId"]{
                if (chateeId == self.otherUserId){
                    appendNewMessage();
                }
            } else{
                return;
            }
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        //grow the dockview
        self.view.layoutIfNeeded();
        UIView.animateWithDuration(0.5, animations: {
            self.dockViewHeightConstraint.constant = 220;
            self.view.layoutIfNeeded();
            }, completion: nil);
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        //shrink the dockview
        self.view.layoutIfNeeded();
        UIView.animateWithDuration(0.5, animations: {
            self.dockViewHeightConstraint.constant = 60;
            self.view.layoutIfNeeded();
            }, completion: nil);
    }
    
    func tableViewTapped(){
        //Tell textview to end editing
        self.messageInputField.endEditing(true);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.messagesTableView.delegate = self;
        self.messagesTableView.dataSource = self;
        self.messageInputField.delegate = self;
        
        //add tap gesture recognizer to tableview
        let tableTapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tableViewTapped");
        
        self.messagesTableView.addGestureRecognizer(tableTapGesture);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "checkNewMessage:", name: ChatManager.sharedInstance.newMessageNotification, object: nil);

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1;
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.chatMessages.count;
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageTableViewCell", forIndexPath: indexPath) as! MessageTableViewCell

        // Configure the cell...
        let msg = self.chatMessages[indexPath.row] as Message
        cell.msg = msg;

        return cell;
    }


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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
