//
//  CircleViewController.swift
//  barr
//
//  Created by Justin Hilliard on 2/26/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

class CircleViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let toggleBar: UIView = UIView()
    var circleCollection: UICollectionView!
    
    let heartButton: UIButton = UIButton()
    let drinkButton: UIButton = UIButton()
    
    var heartDepressed: Bool = false
    var drinkDepressed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 100, left: 0, bottom: 10, right: 0)
        let picSize = screenSize.width*0.7
        layout.itemSize = CGSize(width: picSize, height: picSize)
        
        circleCollection = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        circleCollection.dataSource = self
        circleCollection.delegate = self
        circleCollection.registerClass(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        circleCollection.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(circleCollection)
        defineToggleView()
    }
    
    func defineToggleView(){
        toggleBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: screenSize.size.height*0.15)
        toggleBar.backgroundColor = UIColor.blackColor()
        heartButton.frame = CGRect(x: 0, y: 0, width: 70, height: 50)
        drinkButton.frame = CGRect(x: toggleBar.frame.size.width*0.5, y: 0, width: 70, height: 50)
        heartButton.addTarget(self, action: "heartButtonPressed:", forControlEvents: .TouchUpInside)
        drinkButton.addTarget(self, action: "drinkButtonPressed:", forControlEvents: .TouchUpInside)
        heartButton.backgroundColor = UIColor.purpleColor()
        drinkButton.backgroundColor = UIColor.orangeColor()
        toggleBar.addSubview(heartButton)
        toggleBar.addSubview(drinkButton)
        self.view.addSubview(toggleBar)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 21
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        cell.backgroundColor = UIColor.orangeColor()
//        DownloadImage.downloadImage(NSURL(string: "http://a4.files.biography.com/image/upload/c_fill,cs_srgb,dpr_1.0,g_face,h_300,q_80,w_300/MTE1ODA0OTcxNjMzNjQwOTcz.jpg")!, cell: cell)
        return cell
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func downloadImage(url: NSURL, cell: PhotoCollectionViewCell){
        print("Download Started")
        print("lastPathComponent: " + (url.lastPathComponent ?? ""))
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                print(response?.suggestedFilename ?? "")
                print("Download Finished")
                cell.galleryImage = UIImageView()
                cell.galleryImage.sizeToFit()
                cell.galleryImage.frame.size = CGSize(width: cell.frame.width, height: cell.frame.height)
                cell.galleryImage.frame.origin = CGPoint(x: 0, y: 0)
                cell.galleryImage.image = UIImage(data: data)
                cell.addSubview(cell.galleryImage)
            }
        }
    }
    
    func heartButtonPressed(sender: UIButton!){
        print("heart Hit")
        if heartDepressed == true {
           heartDepressed = false
        } else {
           heartDepressed = true
        }
    }
    
    func drinkButtonPressed(sender: UIButton!){
        print("drink Hit")
        if drinkDepressed == true {
            drinkDepressed = false
        } else {
            drinkDepressed = true
        }
    }
    
}
