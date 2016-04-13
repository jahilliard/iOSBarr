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

class AccountViewController: UIViewController, UIScrollViewDelegate {
    var delegate: cellIndexToAlbumDelegate?
    var picModIndex: Int?
    //number of pages to display in the photo displayer
    let NUM_PAGES = 3;
    var pageViews: [UIImageView?] = [];
    
    @IBOutlet weak var pictureScrollView: UIScrollView!
    let imgCache: NSCache = NSCache();
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true);
    }
    override func viewDidLayoutSubviews() {
        let pageCount = NUM_PAGES;
        for _ in 0..<pageCount {
            self.pageViews.append(nil);
        }
        let pagesScrollViewSize = self.pictureScrollView.frame.size
        pictureScrollView.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(pageCount), height: pagesScrollViewSize.height);
        self.loadVisiblePages();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.pictureScrollView.delegate = self;
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
            print("already loaded");
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
                        newPageView.contentMode = .ScaleAspectFit
                        newPageView.frame = frame
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