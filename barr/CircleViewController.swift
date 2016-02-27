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
    let heartDrinkButton: UIButton = UIButton()
    
    var heartDepressed: Bool = false
    var drinkDepressed: Bool = false
    var heartDrinkDepressed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 90, height: 120)
        
        circleCollection = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        circleCollection.dataSource = self
        circleCollection.delegate = self
        circleCollection.registerClass(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        circleCollection.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(circleCollection)
        defineToggleView()
    }
    
    func defineToggleView(){
        toggleBar.frame = CGRect(x: 0, y: 0, width: screenSize.size.width, height: screenSize.size.height*0.15)
        toggleBar.backgroundColor = UIColor.blackColor()
        self.view.addSubview(toggleBar)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 21
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        cell.backgroundColor = UIColor.orangeColor()
        downloadImage(NSURL(string: "http://a4.files.biography.com/image/upload/c_fill,cs_srgb,dpr_1.0,g_face,h_300,q_80,w_300/MTE1ODA0OTcxNjMzNjQwOTcz.jpg")!, cell: cell)
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
                cell.galleryImage.frame.size = CGSize(width: self.view.frame.width*0.33, height: cell.frame.height)
                cell.galleryImage.frame.origin = CGPoint(x: 0, y: 0)
                cell.galleryImage.image = UIImage(data: data)
                cell.addSubview(cell.galleryImage)
            }
        }
    }
    
    func heartButtonPressed(sender: UIButton!){
        drinkDepressed = false
        heartDrinkDepressed = false
        if heartDepressed == true {
           heartDepressed = false
        } else {
           heartDepressed = true
        }
    }
    
    func drinkButtonPressed(sender: UIButton!){
        heartDepressed = false
        heartDrinkDepressed = false
        if drinkDepressed == true {
            drinkDepressed = false
        } else {
            drinkDepressed = true
        }
    }
    
    func heartDrinkButtonPressed(sender: UIButton!){
        heartDepressed = false
        drinkDepressed = false
        if heartDrinkDepressed == true {
            heartDrinkDepressed = false
        } else {
            heartDrinkDepressed = true
        }
    }
}
