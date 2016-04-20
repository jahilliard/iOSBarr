//
//  FeedTableImageViewCell.swift
//  barr
//
//  Created by Justin Hilliard on 3/31/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

class FeedTableViewImageCell: UITableViewCell{
    
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userNickname: UILabel!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var postText: UITextView!
    @IBOutlet weak var postTextHeightConstraint: NSLayoutConstraint!
    
    func imageTapGesture(sender: AnyObject) {
        self.displayPictureDelegate.displayImage(mainImage.image!);
    }
    
    var entryInfo : FeedEntry!;
    var reloadCellDelegate : ReloadCellDelegate!;
    var displayPictureDelegate: DisplayPictureDelegate!;
    
    func clearCell(){
        self.mainImage.image = nil;
        self.postText.text = nil;
        self.userNickname.text = nil;
        self.userImg.image = nil;
    }
    
    func initCell(entryInfo: FeedEntry, displayPictureDelegate: DisplayPictureDelegate) {
        let imageTapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.imageTapGesture(_:)));
        self.mainImage.addGestureRecognizer(imageTapGesture);
        self.displayPictureDelegate = displayPictureDelegate;
        self.entryInfo = entryInfo;
        self.userNickname.text = entryInfo.authorInfo.nickname;
        self.postText.text = entryInfo.text;
        let fixedWidth = self.postText.frame.size.width;
        let newTextSize : CGSize = self.postText.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max));
        postTextHeightConstraint.constant = newTextSize.height;
        self.layoutIfNeeded();
        /*let newFrameSize = CGSizeMake(fixedWidth, newTextSize.height);
        var newFrame : CGRect = self.postText.frame;
        newFrame.size = newFrameSize;
        self.postText.frame = newFrame;*/
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
