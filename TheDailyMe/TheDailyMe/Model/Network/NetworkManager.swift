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
    
    //Request API KEY
    
    
    //User API
    public func userCreate(id: NSNumber?,
        email: String,
        birthDate: String?,
        firstName: String?,
        lastName: String?,
        password: String,
        avatarImage: NSData?) -> String {
            let identifer = "createUser\(email)"
            var birthData: String? = nil
            if let checkDate = birthDate,
               _ = dateFromString(checkDate) {
                birthData = birthDate
            }
            else {
                birthData = ""
            }
            
            var imageData: String? = nil
            if let checkImage = avatarImage {
                imageData = checkImage.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
            }
            else {
                imageData = ""
            }
            
            let params : [String : AnyObject] = [
                "email": email,
                "firstName": firstName != nil ? firstName! : "",
                "lastName": lastName != nil ? lastName! : "",
                "password": password,
                "birthDate": birthData!,
                "avatarImage": imageData!]
            self.sendDataRequest("POST", endpoint: Constant.String.Endpoint.userCreate, type: RequestType.UserCreate, identifier: identifer, params: params)
            
            return identifer
    }
    
    public func userCreate(user: User) -> String? {
        if let id = user.id,
            email = user.email,
            firstName = user.firstName,
            lastName = user.lastName,
            password = user.password,
            birthDate = user.birthDate,
            avatarImage = user.avatarImage {
                
                let base64String = avatarImage.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
                let identifer = "createUser\(id.integerValue)"
                let params : [String : AnyObject] = [
                    "email": email,
                    "firstName": firstName,
                    "lastName": lastName,
                    "password": password,
                    "birthDate": dateToString(birthDate)!,
                    "avatarImage": base64String]
                self.sendDataRequest("POST", endpoint: Constant.String.Endpoint.userCreate, type: RequestType.UserCreate, identifier: identifer, params: params)
                
                return identifer
                
        }
        return nil
    }
    
    public func userGet(userId: NSNumber) -> String {
        let identifer = "getUser\(userId)"
        self.sendDataRequest("GET", endpoint: "\(Constant.String.Endpoint.user)\(userId.longLongValue)", type: RequestType.UserGet, identifier: identifer)
        return identifer
    }
    
    public func userDelete(userId: NSNumber) -> String {
        let identifer = "deleteUser\(userId)"
        self.sendDataRequest("Delete", endpoint: "\(Constant.String.Endpoint.user)\(userId.longLongValue)", type: RequestType.UserDelete, identifier: identifer)
        return identifer
    }
    
    public func userUpdate(user: User) -> String? {
        if let id = user.id,
            email = user.email,
            firstName = user.firstName,
            lastName = user.lastName,
            password = user.password,
            birthDate = user.birthDate,
            avatarImage = user.avatarImage {
                
                let base64String = avatarImage.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
                let identifer = "updateUser\(id.integerValue)"
                let params : [String : AnyObject] = ["id": id,
                    "email": email,
                    "firstName": firstName,
                    "lastName": lastName,
                    "birthDate": dateToString(birthDate)!,
                    "password": password,
                    "avatarImage": base64String]
                self.sendDataRequest("PUT", endpoint: "\(Constant.String.Endpoint.user)\(user.id!)", type: RequestType.UserUpdate, identifier: identifer, params: params)
                
                return identifer
        }
        return nil
    }
    
    public func userLogin(email : String, password : String) -> String {
        let identifer = "loginUser\(email)"
        let params : [String : AnyObject] = ["email": email,"password": password]
        self.sendDataRequest("POST", endpoint: Constant.String.Endpoint.userLogin, type: RequestType.UserLogin, identifier: identifer, params: params)
        
        return identifer
    }
    
    //Records API
    public func recordCreate(userId: NSNumber, record: Record, question: Question) -> String? {
        
        if let answer = record.answer,
            note = record.note,
            date = record.date,
            stringDate = dateToString(date),
            questionId = question.id,
            questionText = question.text,
            questionDate = question.assignedDate,
            stringAssignDate = dateToString(questionDate) {
                
                let identifer = "createRecord\(record.id?.integerValue)"
                let questionParams = ["id" : questionId, "text" : questionText, "assignedDate" : stringAssignDate];
                let params : [String : AnyObject] = [
                    "answer": answer,
                    "note": note,
                    "date": stringDate,
                    "question": questionParams]
                self.sendDataRequest("POST", endpoint: "\(Constant.String.Endpoint.user)\(userId.longLongValue)\(Constant.String.Endpoint.records)", type: RequestType.RecordCreate, identifier: identifer, params: params)
                return identifer
        }
        return nil
    }
    
    //TODO: schema startDate endDate
    public func recordsGet(userId: NSNumber) -> String {
        let identifer = "getRecord\(userId)"
        self.sendDataRequest("GET", endpoint: "\(Constant.String.Endpoint.user)\(userId.longLongValue)\(Constant.String.Endpoint.records)", type: RequestType.RecordGet, identifier: identifer)
        return identifer
    }
    
    public func recordsUpdate(userId: NSNumber, record: Record, question: Question) -> String? {
        
        if let id = record.id,
            answer = record.answer,
            note = record.note,
            date = record.date,
            stringDate = dateToString(date),
            questionId = question.id,
            questionText = question.text,
            questionDate = question.assignedDate,
            stringAssignDate = dateToString(questionDate) {
                
                let identifer = "updateRecord\(record.id?.integerValue)"
                let questionParams = ["id" : questionId, "text" : questionText, "assignedDate" : stringAssignDate];
                let params : [String : AnyObject] = ["id": id,
                    "answer": answer,
                    "note": note,
                    "date": stringDate,
                    "question": questionParams]
                self.sendDataRequest("PUT", endpoint: "\(Constant.String.Endpoint.user)\(userId.longLongValue)\(Constant.String.Endpoint.recordsUpdate)\(id.longLongValue)", type: RequestType.RecordUpdate, identifier: identifer, params: params)
                return identifer
        }
        return nil
    }
    
    public func recordDelete(userId: NSNumber, recordId: NSNumber) -> String {
        let identifer = "deleteRecord\(recordId)"
        self.sendDataRequest("DELETE", endpoint: "\(Constant.String.Endpoint.user)\(userId.longLongValue)\(Constant.String.Endpoint.recordsUpdate)\(recordId.longLongValue)", type: RequestType.RecordDelete, identifier: identifer)
        return identifer
    }
    
    
    public func questionsGet() -> String {
        let identifer = "getQuestions"
        self.sendDataRequest("GET", endpoint: Constant.String.Endpoint.questionList, type: RequestType.QuestionsGet, identifier: identifer)
        return identifer
    }
    
    public func questionGet(questionId : NSNumber) -> String {
        let identifer = "getQuestion\(questionId)"
        self.sendDataRequest("GET", endpoint: "\(Constant.String.Endpoint.question)\(questionId.longLongValue)", type: RequestType.QuestionGet, identifier: identifer)
        return identifer
    }
    
    public func questionDelete(questionId : NSNumber) -> String {
        let identifer = "deleteQuestion\(questionId)"
        self.sendDataRequest("DELETE", endpoint: "\(Constant.String.Endpoint.question)\(questionId.longLongValue)", type: RequestType.QuestionDelete, identifier: identifer)
        return identifer
    }
    
    public func questionCreate(question : Question, rate : NSNumber) -> String? {
        
        if let text = question.text,
            assignedDate = question.assignedDate {
                
                let identifer = "createQuestion\(assignedDate)"
                let params = ["text" : text, "assignedDate" : assignedDate, "rate" : rate];
                self.sendDataRequest("POST", endpoint: Constant.String.Endpoint.questionCreate, type: RequestType.QuestionCreate, identifier: identifer, params: params)
                return identifer
        }
        return nil
    }
    
    public func questionUpdate(question : Question, rate : NSNumber) -> String? {
        
        if let text = question.text,
            assignedDate = question.assignedDate,
            questionId = question.id {
                
                let identifer = "questionUpdate\(assignedDate)"
                let params = ["text" : text, "assignedDate" : assignedDate, "rate" : rate];
                self.sendDataRequest("PUT", endpoint: "\(Constant.String.Endpoint.question)\(questionId.longLongValue)", type: RequestType.QuestionUpdate, identifier: identifer, params: params)
                return identifer
        }
        return nil
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
            let identifier : Int64 = Int64(arc4random_uniform(1000000000))
            
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
            //User
        case RequestType.UserCreate:
            return self.processUserCreate(requestIdentifier, data: data)
        case RequestType.UserGet:
            return self.processUserGet(requestIdentifier, data: data)
        case RequestType.UserDelete:
            return self.processUserDelete(requestIdentifier, data: data)
        case RequestType.UserUpdate:
            return self.processUserUpdate(requestIdentifier, data: data)
        case RequestType.UserLogin:
            return self.processUserLogin(requestIdentifier, data: data)
            //Records
        case RequestType.RecordGet:
            return self.processRecordGet(requestIdentifier, data: data)
        case RequestType.RecordCreate:
            return self.processRecordCreate(requestIdentifier, data: data)
        case RequestType.RecordDelete:
            return self.processRecordDelete(requestIdentifier, data: data)
        case RequestType.RecordUpdate:
            return self.processRecordUpdate(requestIdentifier, data: data)
            //Questions
        case RequestType.QuestionCreate:
            return self.processQuestionCreate(requestIdentifier, data: data)
        case RequestType.QuestionUpdate:
            return self.processQuestionUpdate(requestIdentifier, data: data)
        case RequestType.QuestionGet:
            return self.processQuestionGet(requestIdentifier, data: data)
        case RequestType.QuestionsGet:
            return self.processQuestionsGet(requestIdentifier, data: data)
        case RequestType.QuestionDelete:
            return self.processRecordDelete(requestIdentifier, data: data)
        default:
            logDebug("\(data)");
            return true
        }
    }
    
    func processUserCreate(requestIdentifier: String, data: Dictionary<String, AnyObject>) -> Bool {
        if let id = data["id"] as? String,
            email = data["email"] as? String {
                
                var avatarImage : NSData? = nil
                if let avatarImageString = data["avatarImage"] as? String {
                    avatarImage = NSData(base64EncodedString: avatarImageString, options: NSDataBase64DecodingOptions(rawValue: 0))
                }
                var birthDate : NSDate? = nil
                if let birthString = data["birthDate"] as? String {
                    birthDate = dateFromString(birthString)
                }
                
                let userId : NSNumber = NSNumber.init(longLong: Int64(id)!)
                DataManager.sharedInstance.setUser(userId,
                    email: email,
                    birthDate:  birthDate,
                    firstName: data["firstName"] as? String,
                    lastName: data["lastName"] as? String,
                    password: data["password"] as? String,
                    avatarImage: avatarImage)
                DataManager.sharedInstance.setUserEmail(email)
                DataManager.sharedInstance.setCoreUser()
                DataManager.sharedInstance.initUserFetch()
                return true
        }
        return false
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

        if let id = data["id"] as? String,
            email = data["email"] as? String {
                
                var avatarImage : NSData? = nil
                if let avatarImageString = data["avatarImage"] as? String {
                    avatarImage = NSData(base64EncodedString: avatarImageString, options: NSDataBase64DecodingOptions(rawValue: 0))
                }
                var birthDate : NSDate? = nil
                if let birthString = data["birthDate"] as? String {
                    birthDate = dateFromString(birthString)
                }
                
                let userId : NSNumber = NSNumber.init(longLong: Int64(id)!)
                DataManager.sharedInstance.setUser(userId,
                    email: email,
                    birthDate:  birthDate,
                    firstName: data["firstName"] as? String,
                    lastName: data["lastName"] as? String,
                    password: data["password"] as? String,
                    avatarImage: avatarImage)
                DataManager.sharedInstance.setUserEmail(email)
                DataManager.sharedInstance.setCoreUser()
                DataManager.sharedInstance.initUserFetch()
                return true
        }
        return false
//        200
//        Returns user profile in case of success login.
//        ⇄
//        User {
//            id: integer
//            email: string
//            firstName: string
//            lastName: string
//            password: string
//            avatarImage: string
//        }
//        400
//        Invalid api key.
//        ⇄
//        Error {
//            message: string
//            code: string
//        }
//        401	
//        Returns error message and code in case of unseccessful authentification.
//        ⇄	
//        Error {
//            message: string
//            code:	string
//        }
//        500	
//        Internal server error.
//        ⇄	
//        Error {
//            message: string
//            code:	string
//        }
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
    
    func processQuestionCreate(requestIdentifier: String, data: Dictionary<String, AnyObject>) -> Bool {
        return true;
    }
    
    func processQuestionUpdate(requestIdentifier: String, data: Dictionary<String, AnyObject>) -> Bool {
        return true;
    }
    
    func processQuestionGet(requestIdentifier: String, data: Dictionary<String, AnyObject>) -> Bool {
        if let questionId = data["questionId"] as? String,
            idInt = Int64(questionId),
            text = data["text"] as? String,
            assignedDate = data["assignedDate"] as? String,
            _ = data["rate"] as? String {
                DataManager.sharedInstance.setQuestion(NSNumber(longLong: idInt), text: text, assignDate: dateFromString(assignedDate)!)
                return true
        }
        
        return false
    }
    
    func processQuestionsGet(requestIdentifier: String, data: Dictionary<String, AnyObject>) -> Bool {
        if let array : NSArray = data["result"] as? NSArray {
            for question in array {
                if let questionId = question["questionId"] as? String,
                   idInt = Int64(questionId),
                   text = question["text"] as? String,
                   assignedDate = question["assignedDate"] as? String,
                   _ = question["rate"] as? String {
                    DataManager.sharedInstance.setQuestion(NSNumber(longLong: idInt), text: text, assignDate: dateFromString(assignedDate)!)
                }
            }
            return true
        }
        
        return false
    }
    
    func processQuestionDelete(requestIdentifier: String, data: Dictionary<String, AnyObject>) -> Bool {
        return true;
    }
}
