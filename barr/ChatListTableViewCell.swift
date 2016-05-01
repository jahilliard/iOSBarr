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
    
    @IBOutlet weak var heart_badge: UIImageView!
    
    @IBOutlet weak var poke_badge: UIImageView!
    
    func initialize(chateeId: String){
        if let chat = ChatManager.sharedInstance.getChat(chateeId) {
            nameLabel.text = chat.chatee.nickname;
            if let previewText = chat.preview {
                self.preview.text = previewText;
            } else {
                self.preview.text = "";
            }
            
            if(chat.containsUnread){
                //do something to signify unread
                print("CONTAINS UNREAD");
            }
            
            if chat.chatee.pictures.count > 0 {
                Circle.getProfilePictureByURL(chat.chatee.pictures[0], completion: {img in self.picture.image = img});
            } else {
                self.picture.image = UIImage(imageLiteral: "defaultProfilePicture.jpg");
            }
            
            if let member = Circle.sharedInstance.getMember(chateeId) {
                if member.otherOffers[UserInfo.OfferOptions.HEART]! {
                    heart_badge.image = UIImage(imageLiteral: "heart_badge.jpg");
                }
                
                if member.otherOffers[UserInfo.OfferOptions.POKE]! {
                    poke_badge.image = UIImage(imageLiteral: "point_badge.jpg");
                }
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
