//
//  MessageTableViewCell.swift
//  barr
//
//  Created by Carl Lin on 3/1/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

protocol CellResendDelegate {
    func resendMsg(msg: Message)
}

class MessageTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var resendButton: UIButton!
    
    var delegate : CellResendDelegate?
    var msg : Message?
    
    @IBAction func OnButtonClick(sender: UIButton)
    {
        self.delegate!.resendMsg(self.msg!);
    }
    
    /*var msg: Message! {
        didSet {
            nameLabel.text = msg.sender;
            messageLabel.text = msg.message;
        }
    }*/
    
    func initialize(msg: Message){
        self.resendButton.hidden = true;
        
        if (msg.status == Message.MessageStatus.FAILED) {
            self.resendButton.hidden = false;
        }
        
        self.msg = msg;
        nameLabel.text = msg.sender;
        messageLabel.text = msg.message;
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
