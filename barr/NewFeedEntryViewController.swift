//
//  NewFeedEntryViewController.swift
//  barr
//
//  Created by Carl Lin on 4/7/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

class NewFeedEntryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIScrollViewDelegate {
    let imagePicker = UIImagePickerController();
    var selectedImage : UIImage? = nil;
    var text : String? = nil;
    
    @IBOutlet weak var scrollArea: UIScrollView!
    var textBox: UITextView = UITextView();
    
    //var postContentArea: UIView!
    
    @IBAction func onImageButtonPressed(sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        self.scrollArea.contentSize.width = self.scrollArea.frame.width;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewFeedEntryViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewFeedEntryViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil);
        
        self.scrollArea.delegate = self
        self.imagePicker.delegate = self;
        self.textBox.delegate = self;
        self.scrollArea.showsHorizontalScrollIndicator = false;
        print(self.scrollArea.frame.width);
        self.scrollArea.contentSize.width = self.scrollArea.frame.width;
        self.scrollArea.contentSize.height = 5;
        self.textBox.text = "Enter New Post...";
        self.textBox.textColor = UIColor.lightGrayColor();
        self.textBox.font = UIFont(name: self.textBox.font!.fontName, size: 18);
        self.resizeTextBox();
        self.textBox.scrollEnabled = false;
        self.scrollArea.addSubview(self.textBox);
        /*print(self.textBox.frame.size);
        self.scrollSpace.contentSize = CGSize(width: self.textBox.frame.size.width, height: self.textBox.contentSize.height);
        self.textBox.contentSize = CGSize(width: self.textBox.frame.size.width, height: self.textBox.contentSize.height);*/
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.selectedImage = pickedImage;
            let image = UIImageView();
            image.contentMode = .ScaleAspectFill;
            image.clipsToBounds = true;
            let imgHeight : CGFloat = 300.0;//min(pickedImage.size.height, self.textBox.frame.height);
            let path = CGRectMake(0, self.scrollArea.contentSize.height, self.scrollArea.frame.width, imgHeight);
            image.frame = path;
            image.image = pickedImage;
            //self.textBox.textContainer.exclusionPaths = [path];
            self.scrollArea.contentSize.height += imgHeight;
            
            self.scrollArea.insertSubview(image, belowSubview: self.textBox);
            print(image.frame);
            print(self.scrollArea.frame);
            print(self.scrollArea.contentSize.width);
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func resizeTextBox() {
        let fixedWidth = self.scrollArea.frame.size.width;
        self.textBox.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max));
        let newHeight = self.textBox.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max)).height;
        let heightDifference = newHeight - self.textBox.frame.height;
        var newFrame = self.textBox.frame;
        newFrame.size = CGSize(width: fixedWidth, height: newHeight);
        self.textBox.frame = newFrame;
        
        for subview in self.scrollArea.subviews {
            if let imgView = subview as? UIImageView {
                imgView.frame.origin.y += heightDifference;
            }
        }
        self.scrollArea.contentSize.height += heightDifference;
    }
    
    func textViewDidChange(textView: UITextView) {
        self.resizeTextBox();
        print(self.textBox.frame.height);
        print(self.scrollArea.contentSize.height);
        print(self.scrollArea.contentSize.width);
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PostNewFeedEntry" {
            self.text = self.textBox.text;
        }
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
