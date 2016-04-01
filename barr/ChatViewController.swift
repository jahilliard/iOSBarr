//
//  ChatViewController.swift
//  barr
//
//  Created by Carl Lin on 3/1/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
    UITextViewDelegate, CellResendDelegate
{
    @IBOutlet weak var sendMsgButton: UIButton!
    @IBOutlet weak var messageInputField: UITextView!
    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet weak var dockViewHeightConstraint: NSLayoutConstraint!
    
    let MARGINS = 10;
    
    var otherUserInfo : UserInfo! {
        didSet {
            self.title = self.otherUserInfo.firstName + " " + self.otherUserInfo.lastName;
        }
    }
    
    private var thisChat: Chat {
        get {
            return ChatManager.sharedInstance.getChat(self.otherUserInfo.userId)!;
        }
    }
    
    private var chatMessages : [Message] {
        get {
            return self.thisChat.messages;
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
        print("VIEW WILL APPEAR");
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "checkNewMessage:", name: ChatManager.sharedInstance.newMessageNotification, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil);
        
        print("OPENING CHAT");
        ChatManager.sharedInstance.openChat(self.otherUserInfo);
    }
    
    override func viewWillDisappear(animated: Bool) {
        print("VIEW WILL DISAPPEAR");
        NSNotificationCenter.defaultCenter().removeObserver(self);
        
        ChatManager.sharedInstance.closeChat();
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
        self.scrollToBottom();
    }
    
    //MARK: Chat messages methods
    func appendNewMessages(newMessageCount: Int){
        print(newMessageCount);
        var updateArray = [NSIndexPath]();
        for (var i = self.chatMessages.count - newMessageCount; i < self.chatMessages.count; i++){
            updateArray.append(NSIndexPath(forRow: i, inSection: 0));
        }
        
        self.messagesTableView.beginUpdates();
        self.messagesTableView.insertRowsAtIndexPaths(updateArray, withRowAnimation: .Automatic)
        self.messagesTableView.endUpdates();
    }
    
    @objc func checkNewMessage(notification : NSNotification){
        if let info = notification.userInfo as? Dictionary<String, AnyObject>,chateeId = info["chateeId"] as? String, count = info["count"] as? Int{
                if (chateeId == self.otherUserInfo.userId){
                    //self.messagesTableView.reloadData();
                    self.appendNewMessages(count);
                    self.scrollToBottom();
                }
            } else {
                return;
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
        cell.initialize(msg);
        cell.delegate = self;
        
        return cell;
    }

    func reloadRow(rowIndex: Int){
        self.messagesTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: rowIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None);
    }

    func findRowForMessagNum(messageNum: Int) -> Int {
        //find row to reload
        var row = 0;
        for (var i = 0; i < self.chatMessages.count; i++){
            if (self.chatMessages[i].messageNum == messageNum){
                row = i;
                break;
            }
        }
        return row;
    }
    func resendMsg(msg: Message) {
        self.reloadRow(self.findRowForMessagNum(msg.messageNum!));
        let alert = UIAlertController(title: "Error", message: "Resend Message?", preferredStyle: UIAlertControllerStyle.Alert);
        alert.addAction(UIAlertAction(title: "Return", style: UIAlertActionStyle.Default, handler: nil));
        alert.addAction(UIAlertAction(title: "Resend", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in self.sendMessage(msg)}));
        self.presentViewController(alert, animated: true, completion: nil);
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
    
    func errorForMsgNumber(msgNumber: Int){
        if let message = self.thisChat.getMsgByMsgNumber(msgNumber) {
            let alert = UIAlertController(title: "Error", message: "Failed to send message", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "Return", style: UIAlertActionStyle.Default, handler: nil));
            self.presentViewController(alert, animated: true, completion: nil);
            
            message.status = Message.MessageStatus.FAILED;
            
            //reload to display resend option
            self.reloadRow(self.findRowForMessagNum(msgNumber));
        }
    }
    
    func addMyMessage(message: String, date: NSDate) -> Message {
        let myMessage = self.thisChat.addMyMessage(message, date: date, status: Message.MessageStatus.PENDING);
    
        //update view with new message
        self.appendNewMessages(1);
        return myMessage;
    }
    
    func sendMessage(myMessage: Message) {
        myMessage.status = Message.MessageStatus.PENDING;
        self.reloadRow(self.findRowForMessagNum(myMessage.messageNum!));
        ChatManager.sharedInstance.sendMessage(self.otherUserInfo.userId, message: myMessage, callback: {(err, data) in
            print("IN CALLBACK");
                if (err != nil) {
                    print(err);
                    if let msgNum = myMessage.messageNum {
                        self.errorForMsgNumber(msgNum);
                    }
                    return;
                }
            
                if let result = data, sentMessage = result["sentMessage"] as? NSDictionary, msgNumber = sentMessage["messageNumber"] as? Int, message = self.thisChat.getMsgByMsgNumber(msgNumber), dateString = sentMessage["date"] as? String, date = Helper.dateFromString(dateString)
                {
                    //update from local datetime to server datetime
                    message.date = date;
                    
                    message.status = Message.MessageStatus.RECEIVED;
                } else {
                    //response was improperly formatted
                    if let msgNum = myMessage.messageNum {
                        self.errorForMsgNumber(msgNum);
                    }
                }
            }
        );
    }
    
    @IBAction func OnButtonClick(sender: UIButton)
    {
        if let text = self.messageInputField.text {
            //shrink the dockview
            self.messageInputField.text = "";
            UIView.animateWithDuration(1, animations: {
                let fixedWidth = self.messageInputField.frame.size.width;
                let newSize : CGSize = self.messageInputField.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max));
                self.dockViewHeightConstraint.constant = newSize.height + CGFloat(self.MARGINS * 2);
                self.view.layoutIfNeeded();
                }, completion: nil);
            
            self.messageInputField.endEditing(true);
            
            //add chat message to the appropriateChat
            let myMessage = self.addMyMessage(text, date: NSDate());
            self.scrollToBottom();
            self.sendMessage(myMessage);
        }
    }

}
