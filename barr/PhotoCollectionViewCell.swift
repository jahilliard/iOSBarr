//
//  PhotoCollectionViewCell.swift
//  SwiftPhotoGallery
//
//  Created by Prashant on 12/09/15.
//  Copyright (c) 2015 PrashantKumar Mangukiya. All rights reserved.
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
        // Initialization code
    }
//    
//    // gallery image
//    var galleryImage: UIImageView = UIImageView()
//    
////    override init(frame: CGRect) {
////        galleryImage = UIImageView()
////        super.init(frame: frame)
////    }
////
////    required init?(coder aDecoder: NSCoder) {
////        fatalError("init(coder:) has not been implemented")
////    }
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }    
    
}
