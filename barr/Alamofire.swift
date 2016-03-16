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

//    static let domain = "http://128.237.219.253:3000/"
    static let domain = "http://10.0.0.3:3000/"
//    static let domain = "http://150.212.45.249:3000/"

    static func authorizedGet(subdomain: String, var parameters: [String: AnyObject], completion: (response: JSON) -> Void){
        if let accessToken = Me.user.accessToken, userId = Me.user.userId {
            parameters["x_key"] = userId;
            parameters["access_token"] = accessToken;
            self.GET(subdomain, parameters: parameters, completion: completion);
        }
    }
    
    static func authorizedPost(subdomain: String, var parameters: [String: AnyObject], completion: ((response: JSON) -> Void)?){
        if let accessToken = Me.user.accessToken, userId = Me.user.userId {
            parameters["x_key"] = userId;
            parameters["access_token"] = accessToken;
            self.POST(subdomain, parameters: parameters, completion: completion);
        }
    }
    
    static func GET(subdomain: String, parameters: [String: AnyObject]?, completion: (response: JSON) -> Void){
        if let params = parameters {
            Alamofire.request(.GET, self.domain + subdomain, headers: headers, parameters: params)
                .validate(statusCode: 200..<300)
                .validate(contentType: ["application/json"])
                .responseJSON { response in
                    switch response.result {
                    case .Success:
                        if let value = response.result.value {
                            let json = JSON(value)
                            completion(response: json);
                        }
                    case .Failure(let error):
                        print(error)
                        print("What happened???")
//                      ErrorHandler.buidErrorView(error)
                    }
            }
        } else {
            Alamofire.request(.GET, self.domain + subdomain, headers: headers, parameters: parameters)
                .validate(statusCode: 200..<300)
                .validate(contentType: ["application/json"])
                .responseJSON { response in
                    switch response.result {
                    case .Success:
                        if let value = response.result.value {
                            let json = JSON(value)
                            completion(response: json);
                        }
                    case .Failure(let error):
                        print(error)
                        print("What happened???")
                        //                      ErrorHandler.buidErrorView(error)
                    }
            }
        }
    }
    
    static func POST(subdomain: String, parameters: [String: AnyObject], completion: ((response: JSON) -> Void)?){
        print(parameters)
        Alamofire.request(.POST, self.domain + subdomain, headers: headers, parameters: parameters, encoding: .JSON)
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
