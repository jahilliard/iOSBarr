//
//  MessageTableViewCell.swift
//  barr
//
//  Created by Carl Lin on 3/1/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    var msg: Message! {
        didSet {
            nameLabel.text = msg.sender;
            messageLabel.text = msg.message;
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
