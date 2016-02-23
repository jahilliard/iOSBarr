//
//  extension.swift
//  barr
//
//  Created by Justin Hilliard on 2/22/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}