//
//  AccountPictureCell.swift
//  barr
//
//  Created by Justin Hilliard on 3/22/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

protocol AccountPictureCellDelegate {
    func preformSegue(cellToMod: AccountPictureCell)
}

class AccountPictureCell: PhotoCollectionViewCell {
    
    var delegate: AccountPictureCellDelegate? = nil
    var accountImg: UIImage?
    var index: Int?
    var isDefault: Bool?
    
    override init(frame: CGRect) {
        
        super.init(frame:frame)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("cellTapped:"))
        super.galleryImage.userInteractionEnabled = true
        super.galleryImage.addGestureRecognizer(tapGestureRecognizer)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cellTapped(sender: UIImageView)  {
        if (delegate != nil) {
            delegate!.preformSegue(self)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}