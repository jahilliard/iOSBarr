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

    static let domain = "http://169.232.216.168:3000/"
//    static let domain = "http://10.0.0.47:3000/"
//    static let domain = "http://192.168.0.10:3000/"

    static func GET(subdomain: String, parameters: [String: AnyObject]?, completion: (response: JSON) -> Void){
        if let params = parameters {
            Alamofire.request(.GET, self.domain + subdomain, headers: headers, parameters: params, encoding: .URL)
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
                        print(response.result.value?.message)
                        print("What happened???")
//                      ErrorHandler.buidErrorView(error)
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
                            completion(response: json);
                        }
                    case .Failure(let error):
                        print(error)
                        print(response.result.value?.message)
                        print("What happened???")
                        //                      ErrorHandler.buidErrorView(error)
                    }
            }
        }
    }
    
    static func POST(subdomain: String, parameters: [String: AnyObject], completion: ((response: JSON) -> Void)?){
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
