//
//  FacebookPhotoCell.swift
//  barr
//
//  Created by Justin Hilliard on 3/6/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

class FacebookPhotoCell: PhotoCollectionViewCell {
    
    var fbCellInfo: FacebookPhotoCellInfo?
    
    let boxSize = CGFloat(25.0)
    var numberSelected: UIView?
    var label: UILabel?
    

    override init(frame: CGRect) {
        super.init(frame:frame)
//        
//        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("cellTapped:"))
//        super.galleryImage.userInteractionEnabled = true
//        super.galleryImage.addGestureRecognizer(tapGestureRecognizer)
    }
    

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setFbImgInfo(fbImgInfo: FacebookPhotoCellInfo){
        self.fbCellInfo = fbImgInfo
        super.setImg(fbImgInfo.img)
        if fbImgInfo.hasBorder {
            self.addBorder(fbImgInfo.selPhotoIndex)
        }
    }
    
//    func passIndex(indexToMod: Int) {
//        
//    }
//    
//    func cellTapped(sender: UIImageView)  {
//        Me.user
//
//    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.deleteBorder()
        self.fbCellInfo = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func addBorder(index: Int){
        if numberSelected == nil || label == nil {
            numberSelected = UIView(frame: CGRect(x: self.layer.frame.width-boxSize, y: self.layer.frame.height-boxSize, width: boxSize, height: boxSize))
            label = UILabel(frame: CGRect(x: self.layer.frame.width-boxSize, y: self.layer.frame.height-boxSize, width: boxSize, height: boxSize))
            label!.font = label!.font.fontWithSize(14)
            self.layer.borderColor = UIColor.blueColor().CGColor
            label!.center = CGPointMake(self.layer.frame.width-(boxSize/2), self.layer.frame.height-(boxSize/2))
            label!.textAlignment = NSTextAlignment.Center
            label!.text = String(format: "%C", 0xe106)
            label!.textColor = UIColor.whiteColor()
            numberSelected!.backgroundColor = UIColor.whiteColor();
        }
        if let numSel = numberSelected, lab = label {
            self.layer.borderWidth = 5
            self.addSubview(numSel)
            self.addSubview(lab)
        }
    }
    
    func deleteBorder(){
        if let numSel = numberSelected, lab = label {
            self.layer.borderWidth = 0
            lab.removeFromSuperview()
            numSel.removeFromSuperview()
        }
    }
    
}