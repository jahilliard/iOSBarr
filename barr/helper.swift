//
//  helper.swift
//  barr
//
//  Created by Carl Lin on 3/10/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import Foundation

class Helper{
    static func dateFromString(dateString: String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ";
        let date = dateFormatter.dateFromString(dateString);
        return date;
    }
}