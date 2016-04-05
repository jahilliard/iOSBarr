//
//  TableViewTextCell.swift
//  barr
//
//  Created by Carl Lin on 4/5/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

class FeedTableViewTextCell: UITableViewCell {

    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userNickname: UILabel!
    @IBOutlet weak var postText: UITextView!
    
    var entryInfo : FeedEntry!;
    
    func initCell(entryInfo: FeedEntry) {
        self.entryInfo = entryInfo;
        self.userNickname.text = entryInfo.authorInfo.nickname;
        Circle.getProfilePicture(entryInfo.authorInfo.userId, completion: {img in self.userImg.image = img});
        self.postText.text = entryInfo.text;
        /*let fixedWidth = self.postText.frame.size.width;
        let newTextSize : CGSize = self.postText.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max));
        let newFrameSize = CGSizeMake(fixedWidth, newTextSize.height);
        var newFrame : CGRect = self.postText.frame;
        newFrame.size = newFrameSize;
        self.postText.frame = newFrame;*/
        self.layoutIfNeeded();
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
