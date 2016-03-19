//
//  UserCellPhotoInfo.swift
//  barr
//
//  Created by Justin Hilliard on 3/18/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import UIKit

class UserCellPhotoInfo {
    let user: UserInfo!
    let indexPath: NSIndexPath
    
    var hasBorder: Bool = false
    var isGreyed: Bool = false
    var selPhotoIndex: Int = -1
    
    init (user: UserInfo, indexPath: NSIndexPath){
        self.user = user;
        self.indexPath = indexPath;
    }
    
}
