//
//  PhotoCollectionViewCell.swift
//  barr
//
//  Created by Justin Hilliard on 2/10/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    var galleryImage: UIImageView = UIImageView()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.galleryImage = UIImageView(frame: CGRect(x: 0, y: 0, width: screenSize.width*0.3, height: screenSize.width*0.3))
        self.galleryImage.contentMode = UIViewContentMode.ScaleAspectFit
        contentView.addSubview(galleryImage)
    }
    
    func setImg(img: UIImage){
        self.galleryImage.image = img
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        galleryImage.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
