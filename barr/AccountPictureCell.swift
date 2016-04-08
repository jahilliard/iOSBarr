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

class AccountPictureCell: UICollectionViewCell {
    
    var delegate: AccountPictureCellDelegate? = nil
    var index: Int?
    var isDefault: Bool?
    
    @IBOutlet weak var accountImg: UIImageView!
    
    func initialize(img: UIImage){
        self.accountImg.image = img
        self.accountImg.contentMode = UIViewContentMode.ScaleAspectFill
    }
    
    override init(frame: CGRect) {
//        accountImg = UIImageView(frame: frame)
        super.init(frame: frame);
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
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