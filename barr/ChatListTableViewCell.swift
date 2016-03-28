//
//  ChatListTableViewCell.swift
//  barr
//
//  Created by Carl Lin on 3/5/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

class ChatListTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var preview: UILabel!
    @IBOutlet weak var picture: UIImageView!
    
    func initialize(chateeId: String){
        if let chat = ChatManager.sharedInstance.getChat(chateeId) {
            nameLabel.text = chat.chatee.firstName + " " + chat.chatee.lastName;
            if let previewText = chat.preview {
                self.preview.text = previewText;
            } else {
                self.preview.text = "";
            }
            
            if(chat.containsUnread){
                //do something to signify unread
                print("CONTAINS UNREAD");
            }
            
            //set photo
            if chat.chatee.pictures.count > 0 {
                let picURL = chat.chatee.pictures[0];
                if let img = Circle.sharedInstance.userCellPhotoInfoCache.objectForKey(picURL) as? UIImage{
                    self.picture.image = img;
                } else {
                    DownloadImage.downloadImage(NSURL(string: picURL)!) {
                        img in
                        self.picture.image = img;
                    }
                }
            } else {
                //set default photo
            }

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
