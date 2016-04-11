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
    @IBOutlet weak var resendButton: UIButton!
    
    var delegate : CellResendDelegate?
    var msg : Message?
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var messageArea: UITextView!
    @IBOutlet weak var bgImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var resendButtonWidthConstraint: NSLayoutConstraint!
    @IBAction func OnButtonClick(sender: UIButton)
    {
        self.resendButtonWidthConstraint.constant = 0.0;
        self.resendButton.hidden = true;
        self.delegate!.resendMsg(self.msg!);
    }
    
    /*var msg: Message! {
        didSet {
            nameLabel.text = msg.sender;
            messageLabel.text = msg.message;
        }
    }*/
    
    func initialize(msg: Message, bgImage: UIImage){
        if self.resendButton != nil {
            self.resendButton.hidden = true;
            self.resendButtonWidthConstraint.constant = 0.0;
        }
        
        if (msg.status == Message.MessageStatus.FAILED) {
            if self.resendButton != nil {
                self.resendButton.hidden = false;
                self.resendButtonWidthConstraint.constant = 52.0;
            }
        }
        
        self.msg = msg;
        messageArea.text = msg.message;
        
        let MAX_WIDTH : CGFloat = 260.0;
        let PADDING: CGFloat = 20.0;
        let constraintRect = CGSize(width: MAX_WIDTH, height: CGFloat.max)
        var newFrame = self.bgImageView.frame;
        let rect = msg.message.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(16.0)], context: nil);
        
        let newWidth = rect.width + PADDING;
        newFrame.size = CGSize(width: newWidth, height: rect.height + PADDING);
        self.bgImageWidthConstraint.constant = newWidth;
        self.messageArea.frame = newFrame;
        self.bgImageView.frame = newFrame;
        self.userInteractionEnabled = false;
        self.bgImageView.image = bgImage;
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
