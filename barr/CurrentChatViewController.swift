//
//  CurrentChatViewController.swift
//  barr
//
//  Created by Justin Hilliard on 2/14/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

class CurrentChatViewController: UIViewController, UITableViewDataSource {
    private var otherUserId = "";
    private var chatMessages = ChatManager.chats[otherUserId];
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
}