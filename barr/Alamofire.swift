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

class requestTracker {
    var isCancelled : Bool = false;
    var isFinished : Bool = false;
    var request : Request!;
    
    func cancel() {
        isCancelled = true;
        
        if isFinished {
            AlamoHelper.deleteFromRequestArray(self);
            return;
        } else {
            request.cancel();
        }
    }
}

struct AlamoHelper {
    static let MAX_ATTEMPTS : UInt64 = 5;
    
    static let domain = "http://107.170.5.135:3000/";
    //static let domain = "http://10.0.0.2:3000/";
    static var requestArray = [requestTracker]();
    
    static private func deleteFromRequestArray(reqTracker: requestTracker) {
        if let index = self.requestArray.indexOf({return $0 === reqTracker}) {
            self.requestArray.removeAtIndex(index);
        }
    }
    static func authorizedGet(subdomain: String, parameters: [String: AnyObject], completion: (err: NSError?, response: JSON?) -> Void){
        if let accessToken = Me.user.accessToken, userId = Me.user.userId {
            var params = parameters;
            params["x_key"] = userId;
            params["access_token"] = accessToken;
            self.GET(subdomain, parameters: params, completion: completion);
        }
    }
    
    static func authorizedPost(subdomain: String, parameters: [String: AnyObject], completion: (err: NSError?, response: JSON?) -> Void) -> requestTracker!
    {
        if let accessToken = Me.user.accessToken, userId = Me.user.userId {
            var params = parameters;
            params["x_key"] = userId;
            params["access_token"] = accessToken;
            return self.POST(subdomain, parameters: params, completion: completion);
        } else {
            print("VERY BAD, user information (access token, id) not available to alamofire");
            return nil;
        }
    }
    
    static func authorizedDelete(subdomain: String, parameters: [String: AnyObject], completion: (err: NSError?, response: JSON?) -> Void){
        if let accessToken = Me.user.accessToken, userId = Me.user.userId {
            var params = parameters;
            params["x_key"] = userId;
            params["access_token"] = accessToken;
            self.DELETE(subdomain, parameters: params, completion: completion);
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
    
    static func POST(subdomain: String, parameters: [String: AnyObject], completion: (err: NSError?,response: JSON?) -> Void) -> requestTracker
    {
        let newRequestTracker = requestTracker();
        self.requestArray.append(requestTracker());
        postAttempt(subdomain, parameters: parameters, completion: completion, attempt: 0, reqTracker: newRequestTracker);
        return newRequestTracker;
    }
    
    static func DELETE(subdomain: String, parameters: [String: AnyObject], completion: (err: NSError?,response: JSON?) -> Void) -> requestTracker{
        let newRequestTracker = requestTracker();
        self.requestArray.append(requestTracker());
        deleteAttempt(subdomain, parameters: parameters, completion: completion, attempt: 0, reqTracker: newRequestTracker);
        return newRequestTracker;
    }
    
    static func postAttempt(subdomain: String, parameters: [String: AnyObject], completion: (err : NSError?, response: JSON?) -> Void, attempt: UInt64, reqTracker: requestTracker){
        let req = Alamofire.request(.POST, self.domain + subdomain, headers: headers, parameters: parameters, encoding: .JSON)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        completion(err: nil, response: json);
                    }
                    
                    reqTracker.isFinished = true;
                    self.deleteFromRequestArray(reqTracker);
                case .Failure(let error):
                    print(error)
                    if reqTracker.isCancelled {
                        reqTracker.isFinished = true;
                        self.deleteFromRequestArray(reqTracker);
                        completion(err: NSError(domain: "Voluntary Cancel", code: 200, userInfo: nil), response: nil);
                    }
                    //reached maximum attempts
                    if (attempt == MAX_ATTEMPTS) {
                        reqTracker.isFinished = true;
                        self.deleteFromRequestArray(reqTracker);
                        completion(err: error, response: nil);
                    } else {
                        //try updating user again
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * attempt * NSEC_PER_SEC)), dispatch_get_main_queue()) {
                            postAttempt(subdomain, parameters: parameters, completion: completion, attempt: attempt + 1, reqTracker: reqTracker);
                        }
                    }
                    if let value = response.result.value {
                        let json = JSON(value)
                        print(json["message"])
                    }
                }
        }
        
        reqTracker.request = req;
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

    static func deleteAttempt(subdomain: String, parameters:[String: AnyObject], completion: (err: NSError?, response: JSON?) -> Void, attempt: UInt64, reqTracker: requestTracker)
    {
        let req = Alamofire.request(.DELETE, self.domain + subdomain, headers: headers, parameters: parameters, encoding: .JSON)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value);
                        reqTracker.isFinished = true;
                        self.deleteFromRequestArray(reqTracker);
                        completion(err: nil, response: json);
                    }
                case .Failure(let error):
                    print(error)
                    //reached maximum attempts
                    if (attempt == MAX_ATTEMPTS) {
                        reqTracker.isFinished = true;
                        self.deleteFromRequestArray(reqTracker);
                        completion(err: error, response: nil);
                    } else {
                        //try updating user again
                        if reqTracker.isCancelled {
                            reqTracker.isFinished = true;
                            self.deleteFromRequestArray(reqTracker);
                            completion(err: error, response: nil);
                            return;
                        }
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * attempt * NSEC_PER_SEC)), dispatch_get_main_queue()) {
                            deleteAttempt(subdomain, parameters: parameters, completion: completion, attempt: attempt + 1, reqTracker: reqTracker);
                        }
                    }
                    if let value = response.result.value {
                        let json = JSON(value)
                        print(json["message"])
                    }
                }
        }
        
        reqTracker.request = req;
    }
}
