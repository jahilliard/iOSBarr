//
//  UserPhotoCell.swift
//  barr
//
//  Created by Justin Hilliard on 3/18/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

protocol UserInfoDelegate {
    
}

class UserPhotoCell: PhotoCollectionViewCell {
    
    var userCellInfo: UserCellPhotoInfo?
    
    let boxSize = CGFloat(25.0)
    var border: UIView?
    
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("cellTapped:"))
        super.galleryImage.userInteractionEnabled = true
        super.galleryImage.addGestureRecognizer(tapGestureRecognizer)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setFbImgInfo(userCellImageInfo: UserCellPhotoInfo){
        self.userCellInfo = userCellImageInfo
        super.setImg(userCellInfo!.user.img)
        if self.userCellInfo.hasBorder {
            self.addBorder(userCellInfo.selPhotoIndex)
        }
        if self.userCellInfo.isGreyed {
            self.greyCell(userCellInfo.selPhotoIndex)
        }
    }
    
    func cellTapped(sender: UIImageView)  {
        if self.userCellInfo?.isGreyed {
            return;
        }
        
    }
    
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
            self.layer.borderColor = UIColor.redColor().CGColor
        }
        if let bord = self.border {
            self.layer.borderWidth = 2
            self.addSubview(bord)
        }
    }
    
    func deleteBorder(){
        if let bord = self.border {
            self.layer.borderWidth = 0
            bord.removeFromSuperview()
        }
    }
    
}
