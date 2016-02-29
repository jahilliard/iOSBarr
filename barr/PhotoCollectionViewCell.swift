//
//  PhotoCollectionViewCell.swift
//  barr
//
//  Created by Justin Hilliard on 2/10/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    var textLabel: UILabel!
    var galleryImage: UIImageView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        galleryImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 159, height: 225))
        galleryImage.contentMode = UIViewContentMode.ScaleAspectFit
        contentView.addSubview(galleryImage)
        
        let textFrame = CGRect(x: 0, y: galleryImage.frame.size.height, width: 159, height: 125)
        textLabel = UILabel(frame: textFrame)
        textLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        textLabel.textAlignment = .Center
        contentView.addSubview(textLabel)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
