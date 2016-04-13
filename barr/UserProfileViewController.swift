//
//  UserProfileViewController.swift
//  barr
//
//  Created by Carl Lin on 3/28/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit
import SwiftyJSON

extension NSLayoutConstraint {
    
    override public var description: String {
        let id = identifier ?? ""
        return "id: \(id), constant: \(constant)" //you may print whatever you want here
    }
}

class UserProfileViewController: UIViewController, UIScrollViewDelegate {
    //@IBOutlet weak var profilePicture: UIImageView!
    var chatDelegate: ChatDelegate!;
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var chatButton: UIButton!
    @IBAction func onChatPressed(sender: AnyObject) {
        self.chatDelegate.displayChat(self.userInfo!);
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    @IBOutlet weak var pokeButton: UIButton!
    @IBAction func onPokePressed(sender: AnyObject) {
        var params = [String: AnyObject]();
        var offers = [String: AnyObject]();
        offers["offers"] = [UserInfo.convertToInt(.POKE)!];
        params["fields"] = offers;
        let subdomain = "api/v1/matches/\(Me.user.userId!)/offers/\(self.userInfo!.userId)"
        AlamoHelper.authorizedPost(subdomain, parameters: params) { (err, response) -> Void in
            if (err != nil) {
                print(err);
                //TODO: notify User
            }
        };
    }
    
    @IBOutlet weak var heartButton: UIButton!
    @IBAction func onHeartPressed(sender: AnyObject) {
        var params = [String: AnyObject]();
        var offers = [String: AnyObject]();
        offers["offers"] = [UserInfo.convertToInt(.HEART)!];
        params["fields"] = offers;
        let subdomain = "api/v1/matches/\(Me.user.userId!)/offers/\(self.userInfo!.userId)"
        AlamoHelper.authorizedPost(subdomain, parameters: params) { (err, response) -> Void in
            if (err != nil) {
                //TODO: notify User
            }
        };
    }
    
    @IBOutlet weak var pictureScrollView: UIScrollView!
    
    //will always be set by the view transferring in
    var userInfo : UserInfo? = nil;
    @IBOutlet weak var pageControl: UIPageControl!
    var pageViews: [UIImageView?] = [];
    
    override func viewDidLayoutSubviews() {
        let pageCount = self.userInfo!.pictures.count;
        pageControl.currentPage = 0;
        pageControl.numberOfPages = pageCount;
        for _ in 0..<pageCount {
            self.pageViews.append(nil)
        }
        let pagesScrollViewSize = self.pictureScrollView.frame.size
        print(pagesScrollViewSize);
        pictureScrollView.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(pageCount),
            height: pagesScrollViewSize.height)
        self.loadVisiblePages();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pictureScrollView.delegate = self;
        self.nickName.text = self.userInfo!.nickname;
        self.pageControl.pageIndicatorTintColor = UIColor.blueColor();
        
        //load the photos in
        /*if self.userInfo.pictures.count > 0 {
            let picURL = userInfo.pictures[0];
            if let img = Circle.sharedInstance.userCellPhotoInfoCache.objectForKey(picURL) as? UIImage{
                //self.profilePicture.image = img;
            } else {
                if let downloadURL = NSURL(string: picURL) {
                    DownloadImage.downloadImage(downloadURL) {
                        img in
                        //self.profilePicture.image = img;
                        Circle.sharedInstance.userCellPhotoInfoCache.setObject(img, forKey: picURL)
                    }
                } else {
                    //TODO: set cell to default
                }
            }
        } else {
            //TODO: set cell to default
        }*/
        // Do any additional setup after loading the view.
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
        if page < 0 || page >= self.userInfo!.pictures.count {
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
            print("PRINTING FRAME");
            print(frame);
            
            // 3
            if self.userInfo!.pictures[page] == "null" {
                let newPageView = UIImageView(image: UIImage(imageLiteral: "defaultProfilePicture.jpg"));
                newPageView.contentMode = .ScaleAspectFit
                newPageView.frame = frame
                self.pictureScrollView.addSubview(newPageView);
                self.pageViews[page] = newPageView;
            } else {
                func completion(err: NSError?, img: UIImage) {
                    if (err != nil) {
                        getImg(self.userInfo!.pictures[page], completion: completion);
                    } else {
                        let newPageView = UIImageView(image: img)
                        newPageView.contentMode = .ScaleAspectFit
                        newPageView.frame = frame
                        self.pictureScrollView.addSubview(newPageView);
                        self.pageViews[page] = newPageView;
                    }
                }
            
                getImg(self.userInfo!.pictures[page], completion: completion);
            }
        }
    }
    
    func purgePage(page: Int) {
        if page < 0 || page >= self.userInfo!.pictures.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // Remove a page from the scroll view and reset the container array
        if let pageView = pageViews[page] {
            pageView.removeFromSuperview()
            pageViews[page] = nil
        }
    }
    
    func loadVisiblePages() {
        // First, determine which page is currently visible
        print(self.pictureScrollView.frame.size);
        let pageWidth = self.pictureScrollView.frame.size.width
        let page = Int(floor((self.pictureScrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        // Update the page control
        pageControl.currentPage = page
        
        // Work out which pages you want to load
        let firstPage = page - 1
        let lastPage = page + 1
        
        // Purge anything before the first page
        if firstPage > 0 {
            for index in 0 ..< firstPage {
                purgePage(index)
            }
        }
        
        // Load pages in our range
        for index in firstPage...lastPage {
            loadPage(index)
        }
        
        // Purge anything after the last page
        if lastPage + 1 < self.userInfo!.pictures.count {
            for index in lastPage+1 ..< self.userInfo!.pictures.count {
                purgePage(index)
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on screen
        self.loadVisiblePages()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.profilePicture;
    }*/

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
