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
    
    
    //test
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
    
    //User API
    public func userCreate(user: User) -> String {
        if let id = user.id,
            email = user.email,
            firstName = user.firstName,
            lastName = user.lastName,
            password = user.password,
            avatarImage = user.avatarImage {
                
                let identifer = "createUser\(id.integerValue)"
                let params : [String : AnyObject] = ["id": id,
                    "email": email,
                    "firstName": firstName,
                    "lastName": lastName,
                    "password": password,
                    "avatarImage": avatarImage]
                self.sendDataRequest("POST", endpoint: Constant.String.Endpoint.userCreate, type: RequestType.UserCreate, identifier: identifer, params: params)
                
                return identifer
                
        }
        return ""
    }
    
    public func userGet(userId: NSNumber) -> String {
        let identifer = "getUser\(userId)"
        self.sendDataRequest("GET", endpoint: "\(Constant.String.Endpoint.user)\(userId)", type: RequestType.UserGet, identifier: identifer)
        return identifer
    }
    
    public func userDelete(userId: NSNumber) -> String {
        let identifer = "deleteUser\(userId)"
        self.sendDataRequest("Delete", endpoint: "\(Constant.String.Endpoint.user)\(userId)", type: RequestType.UserDelete, identifier: identifer)
        return identifer
    }
    
    public func userUpdate(user: User) -> String {
        if let id = user.id,
            email = user.email,
            firstName = user.firstName,
            lastName = user.lastName,
            password = user.password,
            avatarImage = user.avatarImage {
                
                let identifer = "updateUser\(id.integerValue)"
                let params : [String : AnyObject] = ["id": id,
                    "email": email,
                    "firstName": firstName,
                    "lastName": lastName,
                    "password": password,
                    "avatarImage": avatarImage]
                self.sendDataRequest("PUT", endpoint: "\(Constant.String.Endpoint.user)\(user.id)", type: RequestType.UserUpdate, identifier: identifer, params: params)
                
                return identifer
        }
        return ""
    }
    
    public func userLogin(email : String, password : String) -> String {
        let identifer = "loginUser\(email)"
        let params : [String : AnyObject] = ["email": email,"password": password]
        self.sendDataRequest("POST", endpoint: Constant.String.Endpoint.userLogin, type: RequestType.UserLogin, identifier: identifer, params: params)
        
        return identifer
    }
    
    //Records API
    public func recordCreate(userId: NSNumber, record: Record, question: Question) -> String {
        
        if let id = record.id,
            answer = record.answer,
            note = record.note,
            date = record.date,
            stringDate = dateToString(date),
            questionId = question.id,
            questionText = question.text {
                
                let identifer = "createRecord\(record.id?.integerValue)"
                let questionParams = ["id" : questionId, "text" : questionText];
                let params : [String : AnyObject] = ["id": id,
                    "answer": answer,
                    "note": note,
                    "date": stringDate,
                    "question": questionParams]
                self.sendDataRequest("POST", endpoint: "\(Constant.String.Endpoint.user)\(userId)\(Constant.String.Endpoint.records)", type: RequestType.RecordCreate, identifier: identifer, params: params)
                return identifer
        }
        return ""
    }
    
    //TODO: schema startDate endDate
    public func recordsGet(userId: NSNumber) -> String {
        let identifer = "getRecord\(userId)"
        self.sendDataRequest("GET", endpoint: "\(Constant.String.Endpoint.user)\(userId)\(Constant.String.Endpoint.records)", type: RequestType.RecordGet, identifier: identifer)
        return identifer
    }
    
    public func recordsUpdate(userId: NSNumber, record: Record, question: Question) -> String {
        
        if let id = record.id,
            answer = record.answer,
            note = record.note,
            date = record.date,
            stringDate = dateToString(date),
            questionId = question.id,
            questionText = question.text {
                
                let identifer = "updateRecord\(record.id?.integerValue)"
                let questionParams = ["id" : questionId, "text" : questionText];
                let params : [String : AnyObject] = ["id": id,
                    "answer": answer,
                    "note": note,
                    "date": stringDate,
                    "question": questionParams]
                self.sendDataRequest("PUT", endpoint: "\(Constant.String.Endpoint.user)\(userId)\(Constant.String.Endpoint.recordsUpdate)\(id)", type: RequestType.RecordUpdate, identifier: identifer, params: params)
                return identifer
        }
        return ""
    }
    
    public func recordDelete(userId: NSNumber, recordId: NSNumber) -> String {
        let identifer = "deleteRecord\(recordId)"
        self.sendDataRequest("DELETE", endpoint: "\(Constant.String.Endpoint.user)\(userId)\(Constant.String.Endpoint.recordsUpdate)\(recordId)", type: RequestType.RecordDelete, identifier: identifer)
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
        case RequestType.UserCreate:
            return self.processUserCreate(requestIdentifier, data: data)
        default:
            logDebug("\(data)");
            return true
        }
    }
    
    func processUserCreate(requestIdentifier: String, data: Dictionary<String, AnyObject>) -> Bool {
        return true;
    }
    
    func processUserGet(requestIdentifier: String, data: Dictionary<String, AnyObject>) -> Bool {
        return true;
    }
    
    func processUserDelete(requestIdentifier: String, data: Dictionary<String, AnyObject>) -> Bool {
        return true;
    }
    
    func processUserUpdate(requestIdentifier: String, data: Dictionary<String, AnyObject>) -> Bool {
        return true;
    }
    
    func processUserLogin(requestIdentifier: String, data: Dictionary<String, AnyObject>) -> Bool {
        return true;
    }
    
    func processRecordCreate(requestIdentifier: String, data: Dictionary<String, AnyObject>) -> Bool {
        return true;
    }
    
    func processRecordGet(requestIdentifier: String, data: Dictionary<String, AnyObject>) -> Bool {
        return true;
    }
    
    func processRecordUpdate(requestIdentifier: String, data: Dictionary<String, AnyObject>) -> Bool {
        return true;
    }
    
    func processRecordDelete(requestIdentifier: String, data: Dictionary<String, AnyObject>) -> Bool {
        return true;
    }
}
