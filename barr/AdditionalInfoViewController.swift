//
//  AdditionalInfo.swift
//  barr
//
//  Created by Justin Hilliard on 2/22/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

class AdditionalInfoViewController: UIViewController {
    
//    var frameView: UIView!

//    @IBAction func goToMap(sender: AnyObject) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let mapVC: UIViewController = storyboard.instantiateViewControllerWithIdentifier("TabVC")
//        self.presentViewController(mapVC, animated: true, completion: nil)
//    }
    func pressed(sender: UIButton!) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mapVC: UIViewController = storyboard.instantiateViewControllerWithIdentifier("TabVC")
        self.presentViewController(mapVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("NEXT")
        let textFieldAge = UIButton(frame: CGRect(origin: CGPoint(x: screenSize.width*0.125, y: screenSize.height*0.8), size: CGSize(width: screenSize.width*0.8, height: screenSize.width*0.15)))
        textFieldAge.layer.borderWidth = 2.0
        textFieldAge.layer.cornerRadius = 10.0
        textFieldAge.layer.borderColor = UIColor(red: 209, green: 226, blue: 234, alpha: 1).CGColor
        textFieldAge.layer.shadowOpacity = 1.0;
        textFieldAge.layer.shadowRadius = 5.0;
        textFieldAge.layer.shadowColor =  UIColor(red: 209, green: 226, blue: 234, alpha: 1).CGColor
        textFieldAge.layer.shadowOffset = CGSizeMake(0, 0);
        textFieldAge.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
        self.view.addSubview(textFieldAge)

        
//        self.frameView = UIView(frame: CGRectMake(0, 0, screenSize.width, screenSize.height))
        
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: frameView, action: "dismissKeyboard")
//        view.addGestureRecognizer(tap)
        
//        let textFieldNickName = UITextField(frame: CGRect(origin: CGPoint(x: screenSize.width*0.125
//            , y: screenSize.height*0.8), size: CGSize(width: screenSize.width*0.8, height: screenSize.width*0.15)))
//        
//        let textFieldAge = UITextField(frame: CGRect(origin: CGPoint(x: screenSize.width*0.125
//            , y: screenSize.height*0.6), size: CGSize(width: screenSize.width*0.8, height: screenSize.width*0.15)))
//
//        textFieldAge.layer.borderWidth = 2.0
//        textFieldAge.layer.cornerRadius = 10.0
//        textFieldAge.layer.borderColor = UIColor(red: 209, green: 226, blue: 234, alpha: 1).CGColor
//        textFieldAge.layer.shadowOpacity = 1.0;
//        textFieldAge.layer.shadowRadius = 5.0;
//        textFieldAge.layer.shadowColor =  UIColor(red: 209, green: 226, blue: 234, alpha: 1).CGColor
//        textFieldAge.layer.shadowOffset = CGSizeMake(0, 0);
//        
//        textFieldNickName.layer.borderWidth = 2.0
//        textFieldNickName.layer.cornerRadius = 10.0
//        textFieldNickName.layer.borderColor = UIColor(red: 209, green: 226, blue: 234, alpha: 1).CGColor
//        textFieldNickName.layer.shadowOpacity = 1.0;
//        textFieldNickName.layer.shadowRadius = 5.0;
//        textFieldNickName.layer.shadowColor =  UIColor(red: 209, green: 226, blue: 234, alpha: 1).CGColor
//        textFieldNickName.layer.shadowOffset = CGSizeMake(0, 0);
//        
//        self.frameView.addSubview(textFieldAge)
//        self.frameView.addSubview(textFieldNickName)
        
//        self.view.addSubview(self.frameView)
        
        // Keyboard stuff.
//        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
//        center.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
//        center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
//    func keyboardWillShow(notification: NSNotification) {
//        print("String")
//        let info:NSDictionary = notification.userInfo!
//        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
//        
//        let keyboardHeight: CGFloat = keyboardSize.height
//        
//        let _: CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber as CGFloat
//        
//        
//        UIView.animateWithDuration(0.25, delay: 0.25, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
//            self.frameView.frame = CGRectMake(0, (self.frameView.frame.origin.y - keyboardHeight), self.view.bounds.width, self.view.bounds.height)
//            }, completion: nil)
//        
//    }
//    
//    func keyboardWillHide(notification: NSNotification) {
//        let info: NSDictionary = notification.userInfo!
//        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
//        
//        let keyboardHeight: CGFloat = keyboardSize.height
//        
//        let _: CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber as CGFloat
//        
//        UIView.animateWithDuration(0.25, delay: 0.25, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
//            self.frameView.frame = CGRectMake(0, (self.frameView.frame.origin.y + keyboardHeight), self.view.bounds.width, self.view.bounds.height)
//            }, completion: nil)
//        
//    }
//    
//    override func viewWillDisappear(animated: Bool) {
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }
//    
//    func dismissKeyboard() {
//        //Causes the view (or one of its embedded text fields) to resign the first responder status.
//        view.endEditing(true)
//    }
//    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(true)
//    }
}
