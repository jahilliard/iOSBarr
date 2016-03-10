//
//  ChatViewController.swift
//  barr
//
//  Created by Carl Lin on 3/1/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
    UITextViewDelegate
{
    @IBOutlet weak var sendMsgButton: UIButton!
    @IBOutlet weak var messageInputField: UITextView!
    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet weak var dockViewHeightConstraint: NSLayoutConstraint!
    
    let MARGINS = 10;
    
    var otherUserId : String! {
        didSet {
            self.title = self.otherUserId;
        }
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
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.messagesTableView.delegate = self;
        self.messagesTableView.dataSource = self;
        self.messageInputField.delegate = self;
        
        //add tap gesture recognizer to tableview
        let tableTapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tableViewTapped");
        
        self.messagesTableView.addGestureRecognizer(tableTapGesture);
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "checkNewMessage:", name: ChatManager.sharedInstance.newMessageNotification, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil);
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* TODO:
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }*/

    func scrollToBottom(){
        if(self.chatMessages.count > 0){
            self.messagesTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.chatMessages.count-1 , inSection: 0), atScrollPosition: .Bottom, animated: false)
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
                print("SHOWING KEYBOARD");
                let oldRect = self.view.frame;
                print(oldRect.height);
                print(oldRect.origin);
                print(keyboardSize.height);
                self.view.frame = CGRectMake(oldRect.origin.x, oldRect.origin.y, oldRect.width, oldRect.height - keyboardSize.height);
                self.view.layoutIfNeeded();
                self.scrollToBottom();
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
                print("HIDING KEYBOARD");
                let oldRect = self.view.frame;
                print(oldRect.height);
                print(oldRect.origin);
                print(keyboardSize.height);
                self.view.frame = CGRectMake(oldRect.origin.x, oldRect.origin.y, oldRect.width, oldRect.height + keyboardSize.height);
                self.view.layoutIfNeeded();
            }
        }
    }
    
    //MARK: TextView delegate methods
    /*func textViewDidBeginEditing(textView: UITextView) {
        //grow the dockview
        self.view.layoutIfNeeded();
        UIView.animateWithDuration(0.5, animations: {
            self.dockViewHeightConstraint.constant = CGFloat(self.KEYBOARD_HEIGHT);
            self.view.layoutIfNeeded();
            }, completion: nil);
    }*/
    
    /*func textViewDidEndEditing(textView: UITextView) {
    }*/
    
    func textViewDidChange(textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        let newSize : CGSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max));
        self.dockViewHeightConstraint.constant = newSize.height + CGFloat(self.MARGINS * 2);
        self.view.layoutIfNeeded();
    }
    
    //MARK: Chat messages methods
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
    
    //MARK: Tableview delegate methods
    func tableViewTapped(){
        //Tell textview to end editing
        self.messageInputField.endEditing(true);
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
    
    func sendMessage(message: String) {
        ChatManager.sharedInstance.sendMessage(self.otherUserId, message: message, callback: {(err, data) in
                if (err != nil) {
                    let alert = UIAlertController(title: "Error", message: "Failed to send message", preferredStyle: UIAlertControllerStyle.Alert);
                    alert.addAction(UIAlertAction(title: "Return", style: UIAlertActionStyle.Default, handler: nil));
                    self.presentViewController(alert, animated: true, completion: nil);
                } else {
                    self.scrollToBottom();
                    self.messageInputField.text = "";
                    //shrink the dockview
                    UIView.animateWithDuration(1, animations: {
                        let fixedWidth = self.messageInputField.frame.size.width;
                        let newSize : CGSize = self.messageInputField.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max));
                        self.dockViewHeightConstraint.constant = newSize.height + CGFloat(self.MARGINS * 2);
                        self.view.layoutIfNeeded();
                        }, completion: nil);
                    
                    self.messageInputField.endEditing(true);
                }
            }
        );
    }
    
    @IBAction func OnButtonClick(sender: UIButton)
    {
        if let text = self.messageInputField.text {
            self.sendMessage(text);
        }
    }

}
