//
// NetworkManager.swift
//  PicPlay
//
//  Created by Aleksey Orlov on 6/17/15.
//  Copyright (c) 2015 Picsolve. All rights reserved.
//

import Foundation
import CoreData

public class NetworkManager:CoreNetworkManager
{
    public static let sharedInstance = NetworkManager()
    
    
    public func getSomeData() -> String {
        let identifer = "TestEndPoint"
        self.sendDataRequest("GET", endpoint: Constant.String.Endpoint.testEndpoint, type: RequestType.TestEndpoint, identifier: identifer)
//        self.sendDataRequest("POST", endpoint: Constant.String.Endpoint.testEndpoint, type: RequestType.TestEndpoint, identifier: identifer, params: params)
        return identifer
    }
    
    public func postSomeData() -> String {
        let identifer = "TestEndPoint"
        let params = ["userEMail": "pinkypinkyhorror@gmail.com"]
        self.sendDataRequest("POST", endpoint: Constant.String.Endpoint.testEndpointPost, type: RequestType.TestEndpoint, identifier: identifer, params: params)
        return identifer
    }
    
    //MARK: Download file requests
    /**
    Download file from specific url.
    
    - parameter url: File url.
    
    - returns: Unique request identifier.
    */
    public func downloadFile(url: String) -> String {
        let identifier = url
        self.sendDownloadRequest(url)
        return identifier
    }
    
    //MARK: Overridden methods
    /**
    Update local cache of API response.
    
    - parameter response:          API response.
    - parameter requestType:       Type of the request. SeeRequestType enumeration for possible values.
    - parameter requestIdentifier: Unique request identifier.
    */
    override func updateMetadata(response: NSURLResponse?, requestType:RequestType, requestIdentifier: String) {
        if let httpResponse = response as? NSHTTPURLResponse {
            let headers = httpResponse.allHeaderFields
            let identifier = "type=\(requestType.rawValue), identifier=\(requestIdentifier)"
            
            if let eTag = headers["ETag"] as? String,
                cacheControl = headers["Cache-Control"] as? String,
                metadata = DataManager.sharedInstance.createEntity("EndpointMetadata", withID: identifier) as?EndpointMetadata {
                var changes = ["eTag": eTag,
                               "requestIdentifier": requestIdentifier,
                               "requestType":  NSNumber(integer: requestType.rawValue)]
                
                var maxAge: NSString = ""
                if let regex = try? NSRegularExpression(pattern: "\\d+", options: []),
                    range = regex.firstMatchInString(cacheControl, options: [], range: NSMakeRange(0, cacheControl.characters.count)) {
                        maxAge = (cacheControl as NSString).substringWithRange(range.range)
                }
                
                let seconds = maxAge.doubleValue
                if seconds > 0.0 {
                    let nextUpdateDate = NSDate().dateByAddingTimeInterval(seconds as NSTimeInterval)
                    changes.updateValue(nextUpdateDate, forKey: "nextUpdateDate")
                }
                
               Parser.updateEntity(metadata, withProperties: changes, saveContext: true)
            }
        }
    }
    
    /**
    Retrieves custom error from API response data.
    
    - parameter data: API response data.
    
    - returns: Custom error code. SeeErrorCode enumeration for possible values.
    */
    override func getCustomErrorCode(data: Dictionary<String, AnyObject>) ->ErrorCode {
        if let codes = data["errorCodes"] as? Array<String> {
            if codes.count > 0 {
                if let code = ErrorCode(rawValue: codes[0]) {
                    return code
                }
            }
        }
        
        return .UnknownError
    }
    
    /**
    Main function for processing API response data.
    
    - parameter requestType:       Type of the request. SeeRequestType enumeration for possible values.
    - parameter requestIdentifier: Unique request identifier.
    - parameter data:              API response data.
    
    - returns: true if response data is applied successfully, false otherwise.
    */
    override func processResponseData(requestType:RequestType, requestIdentifier: String, data: Dictionary<String, AnyObject>) -> Bool {
        switch requestType {
        case RequestType.TestEndpoint:
            logDebug("\(data)")
            return true
        default:
            logDebug("\(data)");
            return true
        }
    }
}
