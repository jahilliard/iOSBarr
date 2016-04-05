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
    
    var entryInfo : FeedEntry!;
    var reloadCellDelegate : ReloadCellDelegate!;
    
    func initCell(entryInfo: FeedEntry, reloadCellDelegate: ReloadCellDelegate) {
        self.reloadCellDelegate = reloadCellDelegate;
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
        
        if let img = self.entryInfo.mainImage {
            self.mainImage.image = img;
        } else {
            Circle.getProfilePicture(entryInfo.authorInfo.userId, completion: {img in self.userImg.image = img});
            
            AlamoHelper.getFeedMedia(self.entryInfo.entryId, callback: {(err, data) in
                if err != nil || data == nil{
                    //TODO: notify user on screen of connection/get error
                    return;
                } else {
                    if let image = UIImage(data: data!) {
                        self.entryInfo.mainImage = image;
                        self.mainImage.image = image;
                        self.entryInfo.imageHeight = image.size.height;
                        reloadCellDelegate.reloadCellWithEntryId(self.entryInfo.entryId);
                    } else {
                        //TODO: handle bad image
                    }
                }
            });
        }
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
