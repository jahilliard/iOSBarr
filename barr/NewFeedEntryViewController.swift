//
//  NewFeedEntryViewController.swift
//  barr
//
//  Created by Carl Lin on 4/7/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

class NewFeedEntryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let imagePicker = UIImagePickerController();
    var selectedImage : UIImage? = nil;
    
    @IBOutlet weak var scrollArea: UIScrollView!
    @IBOutlet weak var textBox: UITextView!
    
    @IBOutlet weak var postContentArea: UIView!
    
    @IBAction func onImageButtonPressed(sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewFeedEntryViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewFeedEntryViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil);
        
        self.imagePicker.delegate = self;
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
            let image = UIImageView(image: pickedImage);
            image.contentMode = .ScaleAspectFill;
            let imgHeight = min(pickedImage.size.height, self.textBox.frame.height);
            let path = CGRectMake(0, self.postContentArea.frame.origin.y + self.postContentArea.frame.height, self.textBox.frame.width, imgHeight);
            print(self.textBox.contentSize.height);
            image.frame = path;
            //self.textBox.textContainer.exclusionPaths = [path];
            self.postContentArea.frame = CGRectMake(self.postContentArea.frame.origin.x, self.postContentArea.frame.origin.y, self.postContentArea.frame.width, postContentArea.frame.height + imgHeight);
            
            self.postContentArea.addSubview(image);
            self.postContentArea.layoutIfNeeded();
            self.scrollArea.layoutIfNeeded();
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
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
