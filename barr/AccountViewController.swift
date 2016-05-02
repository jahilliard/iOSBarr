//
//  AccountViewController.swift
//  barr
//
//  Created by Justin Hilliard on 2/13/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

protocol cellIndexToAlbumDelegate{
    func cellIndexToAlbum(index: Int)
}

class AccountViewController: UIViewController, UIScrollViewDelegate, UITextViewDelegate, UITextFieldDelegate {
    var delegate: cellIndexToAlbumDelegate?
    var picModIndex: Int?
    @IBOutlet weak var postButton: UIButton!
    //number of pages to display in the photo displayer
    let NUM_PAGES = 3;
    let POST_BUTTON_HEIGHT : CGFloat = 30;
    let MIN_TEXTVIEW_HEIGHT : CGFloat = 100;
    var pageViews: [UIImageView?] = [];
    var keyboardIsShown = false;
    
    @IBOutlet weak var nicknameLabel: UITextField!
    //@IBOutlet weak var nicknameDoneButtonHeightConstraint: NSLayoutConstraint!
    
    @IBAction func onNicknameDoneButtonPress(sender: AnyObject) {
        self.postButton.hidden = true;
        self.nicknameLabel.enabled = false;
        func callback(err: NSError?) {
            self.nicknameLabel.enabled = true;
            if err != nil{
                let alert = UIAlertController(title: "Error", message: "Failed to set nickname", preferredStyle: UIAlertControllerStyle.Alert);
                alert.addAction(UIAlertAction(title: "Return", style: UIAlertActionStyle.Default, handler: nil));
                return;
            } else {
                Me.user.status = self.statusTextView.text;
            }
        }
    
        if let text = self.nicknameLabel.text {
            Me.user.updateUser(["nickname": text], completion: callback);
        }
    }

    @IBOutlet weak var nickNameDoneButton: UIButton!
    @IBAction func onSendStatusButtonPress(sender: AnyObject) {
        self.statusTextView.editable = false;
        
        func callback(err: NSError?) {
            self.statusTextView.editable = true;
            if err != nil{
                let alert = UIAlertController(title: "Error", message: "Failed to set status", preferredStyle: UIAlertControllerStyle.Alert);
                alert.addAction(UIAlertAction(title: "Return", style: UIAlertActionStyle.Default, handler: nil));
                return;
            } else {
                Me.user.status = self.statusTextView.text;
            }
        }
        
        if self.statusTextView.text != "" {
            Me.user.updateUser(["status": self.statusTextView.text], completion: callback);
        }
    }
    
    @IBOutlet weak var postButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageScrollView: UIScrollView!
    @IBOutlet weak var statusTextView: UITextView!
    @IBOutlet weak var pictureScrollView: UIScrollView!
    let imgCache: NSCache = NSCache();
    
    @IBOutlet weak var statusTextViewHeightConstraint: NSLayoutConstraint!
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true);
    }
    
    override func viewDidLayoutSubviews() {
        let pageCount = NUM_PAGES;
        let pagesScrollViewSize = self.pictureScrollView.frame.size;

        for subview in self.pictureScrollView.subviews {
            if let s = subview as? UIImageView {
                s.removeFromSuperview();
            }
        }
        
        self.pageViews = [UIImageView?](count: pageCount, repeatedValue: nil);
        
        pictureScrollView.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(pageCount), height: pagesScrollViewSize.height);
        
        self.loadVisiblePages();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        if let f_name = Me.user.firstName, l_name = Me.user.lastName {
            self.navigationItem.title = "\(f_name) \(l_name)";
        } else {
            self.navigationItem.title = "Account View";
        }
        self.nickNameDoneButton.hidden = true;
        self.postButtonHeightConstraint.constant = 0;
        self.postButton.hidden = true;
        self.pictureScrollView.delegate = self;
        self.statusTextView.delegate = self;
        self.nicknameLabel.delegate = self;
        self.statusTextView.layer.borderColor = UIColor.lightGrayColor().CGColor;
        self.statusTextView.layer.borderWidth = 0.5;
        self.statusTextViewHeightConstraint.constant = MIN_TEXTVIEW_HEIGHT;
        self.view.layoutIfNeeded();
        
        if Me.user.nickname != "" {
            self.nicknameLabel.text = Me.user.nickname;
        } else {
            self.nicknameLabel.text = "Enter Nickname Here";
            self.nicknameLabel.textColor = UIColor.lightGrayColor();
        }
        
        if Me.user.status != "" {
            self.statusTextView.text = Me.user.status;
        } else {
            self.statusTextView.text = "Enter Status Here";
            self.statusTextView.textColor = UIColor.lightGrayColor();
        }
        
        view.backgroundColor = UIColor(patternImage: UIImage(named:"background.png")!)

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AccountViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AccountViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil);
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(AccountViewController.handleSingleTap(_:))));
    }
    
    func handleSingleTap(sender: AnyObject) {
        self.view.endEditing(true);
    }
    
    func adjustInsetForKeyboardShow(show: Bool, notification: NSNotification) {
        guard let value = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue else { return };
        let keyboardFrame = value.CGRectValue()
        let adjustmentHeight = (CGRectGetHeight(keyboardFrame) + 5) * (show ? 1 : -1)
        self.pageScrollView.contentInset.bottom += adjustmentHeight
        self.pageScrollView.scrollIndicatorInsets.bottom += adjustmentHeight
    }
 
    
    func keyboardWillShow(notification: NSNotification) {
        if (self.keyboardIsShown) {
            return;
        }
        
        self.keyboardIsShown = true;
        
        self.adjustInsetForKeyboardShow(true, notification: notification);
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if (!self.keyboardIsShown) {
            return;
        }
        
        self.keyboardIsShown = false;
        
        self.adjustInsetForKeyboardShow(false, notification: notification);
    }
    
    func getImg(url : String, completion: (NSError?, UIImage) -> Void) {
        if let img = Circle.sharedInstance.userCellPhotoInfoCache.objectForKey(url) as? UIImage{
            return completion(nil, img);
        } else {
            if let downloadURL = NSURL(string: url) {
                DownloadImage.downloadImage(downloadURL) {
                    img in
                    Circle.sharedInstance.userCellPhotoInfoCache.setObject(img, forKey: url);
                    return completion(nil, img);
                }
            } else {
                //TODO: set cell to default
                //return completion(default);
            }
        }
    }
    
    func loadPage(page: Int) {
        if page < 0 || page >= NUM_PAGES {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // 1
        if let pageView = pageViews[page] {
            // Do nothing. The view is already loaded.
        } else {
            // 2
            var frame = self.pictureScrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            
            // 3
            var newPageView = UIImageView();
            newPageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageTapGesture(_:))));
            newPageView.userInteractionEnabled = true;
            
            if  page >= Me.user.picturesArr?.count || Me.user.picturesArr![page] == "null" {
                newPageView.image = UIImage(imageLiteral: "defaultProfilePicture.jpg");
                newPageView.contentMode = .ScaleAspectFit
                newPageView.frame = frame
                self.pictureScrollView.addSubview(newPageView);
                self.pageViews[page] = newPageView;
            } else {
                func completion(err: NSError?, img: UIImage) {
                    if (err != nil) {
                        getImg(Me.user.picturesArr![page], completion: completion);
                    } else {
                        newPageView.image = img;
                        newPageView.contentMode = .ScaleAspectFit;
                        newPageView.frame = frame;
                        self.pictureScrollView.addSubview(newPageView);
                        self.pageViews[page] = newPageView;
                    }
                }
                
                getImg(Me.user.picturesArr![page], completion: completion);
            }
        }
    }
    
    func purgePage(page: Int) {
        if page < 0 || page >= self.NUM_PAGES {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // Remove a page from the scroll view and reset the container array
        if let pageView = pageViews[page] {
            pageView.removeFromSuperview();
            pageViews[page] = nil;
        }
    }
    
    func loadVisiblePages() {
        // First, determine which page is currently visible
        print(self.pictureScrollView.frame.size);
        let pageWidth = self.pictureScrollView.frame.size.width
        let page = Int(floor((self.pictureScrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        // Work out which pages you want to load
        let firstPage = page - 1
        let lastPage = page + 1
        
        // Purge anything before the first page
        if firstPage > 0 {
            for index in 0 ..< firstPage {
                //purgePage(index)
            }
        }
        
        // Load pages in our range
        for index in firstPage...lastPage {
            loadPage(index)
        }
        
        // Purge anything after the last page
        if lastPage + 1 < self.NUM_PAGES {
            for index in lastPage+1 ..< self.NUM_PAGES {
                //purgePage(index)
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on screen
        self.loadVisiblePages()
    }
    
    func sendToLogin(){
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let mapVC: UIViewController = storyboard.instantiateViewControllerWithIdentifier("LoginScreen")
        self.presentViewController(mapVC, animated: true, completion: nil)
    }
    
    
    @IBAction func logoutButton(sender: AnyObject) {
        if (FBSDKAccessToken.currentAccessToken() != nil){
            FBSDKLoginManager().logOut()
            sendToLogin()
        } else {
            sendToLogin()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "selectAlb") {
            let selectAlb: SelectAlbumViewController = segue.destinationViewController as! SelectAlbumViewController
            delegate = selectAlb
            if delegate != nil {
                delegate!.cellIndexToAlbum(picModIndex!)
            }
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.textColor == UIColor.lightGrayColor() {
            textField.text = nil;
            textField.textColor = UIColor.blackColor();
        }
        
        self.nickNameDoneButton.hidden = false;
        //self.nicknameDoneButtonHeightConstraint.constant = self.POST_BUTTON_HEIGHT;
        self.view.layoutIfNeeded();
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.nickNameDoneButton.hidden = true;
        //self.nicknameDoneButtonHeightConstraint.constant = 0;
        self.view.layoutIfNeeded();
    }
    
    func textViewDidChange(textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        let newSize : CGSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max));
        
        print(textView.text);
        if newSize.height > MIN_TEXTVIEW_HEIGHT {
            self.statusTextViewHeightConstraint.constant = newSize.height;
        }
        
        else if self.statusTextViewHeightConstraint.constant > MIN_TEXTVIEW_HEIGHT{
            self.statusTextViewHeightConstraint.constant = MIN_TEXTVIEW_HEIGHT;
        }
        
        self.view.layoutIfNeeded();
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor();
        }
        
        self.postButton.hidden = false;
        self.postButtonHeightConstraint.constant = self.POST_BUTTON_HEIGHT;
        self.view.layoutIfNeeded();
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        self.postButton.hidden = true;
        self.postButtonHeightConstraint.constant = 0;
        self.view.layoutIfNeeded();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imageTapGesture(sender: AnyObject) {
        let pageWidth = self.pictureScrollView.frame.size.width;
        let page = Int(floor((self.pictureScrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)));
        self.picModIndex = page;
        self.performSegueWithIdentifier("selectAlb", sender: self);
    }
}