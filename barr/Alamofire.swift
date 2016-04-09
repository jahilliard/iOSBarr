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

    static let domain = "http://10.0.0.2:3000/"

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
    
    static func getFeedMedia(resourceId : String, callback: (NSError?, NSData?) -> Void) {
        let mediaURL = self.domain + "api/v1/feed/" + resourceId + "/content";
        if let accessToken = Me.user.accessToken, userId = Me.user.userId {
            var params : [String: AnyObject] = [String: AnyObject]();
            params["x_key"] = userId;
            params["access_token"] = accessToken;
            Alamofire.request(.GET, mediaURL, parameters: params).response() {
                (request, response, data, err) in
                if err != nil {
                    print(err);
                    //TODO: handle error
                    return;
                }

                callback(nil, data);
            }
        }
    }
    
    static func postNewFeedEntry(img: UIImage?, params: [String: AnyObject], completion: (err : NSError?, response: JSON?) -> Void)
    {
        var params = params;
        if let accessToken = Me.user.accessToken, userId = Me.user.userId {
            params["x_key"] = userId;
            params["access_token"] = accessToken;
        } else {
            completion(err: NSError(domain: "user was never authenticated", code: 400, userInfo: nil), response: nil);
        }
        
        Alamofire.upload(.POST, domain + "api/v1/feed", multipartFormData: {
            multipartFormData in
            
            if let uploadImg = img {
                if let imageData = UIImageJPEGRepresentation(uploadImg, 0.5) {
                    multipartFormData.appendBodyPart(data: imageData, name: "newFile", fileName: "file.png", mimeType: "image/png")
                }
            }
            
            for (key, value) in params {
                multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
            }
            
            }, encodingCompletion: { encodingResult in
                switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.responseJSON { response in
                            //success block
                            if let value = response.result.value {
                                completion(err: nil, response: JSON(value));
                            }
                        }
                        
                        /*upload.progress { _, totalBytesRead, totalBytesExpectedToRead in
                            let progress = Float(totalBytesRead)/Float(totalBytesExpectedToRead)
                            // progress block
                        }*/
                    
                    case .Failure(let error):
                        //failure block
                        completion(err: error as NSError, response: nil);
                }
        });
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
