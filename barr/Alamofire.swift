//
//  Alamofire.swift
//  barr
//
//  Created by Justin Hilliard on 2/18/16.
//  Copyright © 2016 barrapp. All rights reserved.
//

import Alamofire
import SwiftyJSON

let headers = [
    "content-type": "application/json"
]

struct AlamoHelper {
    static let MAX_ATTEMPTS : UInt64 = 5;

    static let domain = "http://192.168.0.17:3000/"

    static func authorizedGet(subdomain: String, var parameters: [String: AnyObject], completion: (err: NSError?, response: JSON?) -> Void){
        if let accessToken = Me.user.accessToken, userId = Me.user.userId {
            parameters["x_key"] = userId;
            parameters["access_token"] = accessToken;
            self.GET(subdomain, parameters: parameters, completion: completion);
        }
    }
    
    static func authorizedPost(subdomain: String, var parameters: [String: AnyObject], completion: (err: NSError?, response: JSON?) -> Void){
        if let accessToken = Me.user.accessToken, userId = Me.user.userId {
            parameters["x_key"] = userId;
            parameters["access_token"] = accessToken;
            self.POST(subdomain, parameters: parameters, completion: completion);
        }
    }
    
    static func GET(subdomain: String, parameters: [String: AnyObject]?, completion: (err : NSError?, response: JSON?) -> Void){
        getAttempt(subdomain, parameters: parameters, completion: completion, attempt: 0);
    }
    
    static func getAttempt(subdomain: String, parameters: [String: AnyObject]?, completion: (err: NSError?, response: JSON?) -> Void, attempt: UInt64){
        if let params = parameters {
            print(self.domain + subdomain)
            Alamofire.request(.GET, self.domain + subdomain, headers: headers, parameters: params, encoding: .URL)
                .validate(statusCode: 200..<300)
                .validate(contentType: ["application/json"])
                .responseJSON { response in
                    switch response.result {
                        case .Success:
                            if let value = response.result.value {
                                let json = JSON(value)
                                completion(err: nil, response: json);
                            }
                        case .Failure(let error):
                            print(error)
                            if (attempt == MAX_ATTEMPTS) {
                                completion(err: error, response: nil);
                            } else {
                                //do some sort of backoff
                                let nextAttempt : UInt64 = attempt + 1;
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * nextAttempt * NSEC_PER_SEC)), dispatch_get_main_queue()) {
                                    print(nextAttempt);
                                    getAttempt(subdomain, parameters: parameters, completion:  completion, attempt: nextAttempt);
                                    };
                            }
                    }
            }
        } else {
            Alamofire.request(.GET, self.domain + subdomain, headers: headers, encoding: .URL)
                .validate(statusCode: 200..<300)
                .validate(contentType: ["application/json"])
                .responseJSON { response in
                    switch response.result {
                        case .Success:
                            if let value = response.result.value {
                                let json = JSON(value)
                                completion(err: nil, response: json);
                            }
                        case .Failure(let error):
                            print(error)
                            if (attempt == MAX_ATTEMPTS) {
                                completion(err: error, response: nil);
                            } else {
                                //do some sort of backoff
                                let nextAttempt : UInt64 = attempt + 1;
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * nextAttempt * NSEC_PER_SEC)), dispatch_get_main_queue()) {
                                    getAttempt(subdomain, parameters: parameters, completion:  completion, attempt: nextAttempt);
                                };
                            }
                    }
            }
        }
    }
    
    static func POST(subdomain: String, parameters: [String: AnyObject], completion: (err: NSError?,response: JSON?) -> Void){
        postAttempt(subdomain, parameters: parameters, completion: completion, attempt: 0);
    }
    
    static func postAttempt(subdomain: String, parameters: [String: AnyObject], completion: (err : NSError?, response: JSON?) -> Void, attempt: UInt64){
        Alamofire.request(.POST, self.domain + subdomain, headers: headers, parameters: parameters, encoding: .JSON)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        completion(err: nil, response: json);
                    }
                case .Failure(let error):
                    print(error)
                    //reached maximum attempts
                    if (attempt == MAX_ATTEMPTS) {
                        completion(err: error, response: nil);
                    } else {
                        //try updating user again
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * attempt * NSEC_PER_SEC)), dispatch_get_main_queue()) {
                            postAttempt(subdomain, parameters: parameters, completion: completion, attempt: attempt + 1);
                        }
                    }
                    if let value = response.result.value {
                        let json = JSON(value)
                        print(json["message"])
                    }
                }
        }
    }
    
    static func DELETE(subdomain: String, parameters:[String: AnyObject], completion: ((response: JSON) -> Void)?){
        Alamofire.request(.DELETE, self.domain + subdomain, headers: headers, parameters: parameters, encoding: .JSON)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                    case .Success:
                        if let value = response.result.value {
                            let json = JSON(value)
                            if let compBlock = completion {
                                compBlock(response: json);
                            }
                        }
                    case .Failure(let error):
                        print(error)
                }
        }
    }
}
