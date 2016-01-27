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
    
    //MARK: Part endpoints
    /**
    Request parks from appropriate API endpoint.
    
    - returns: Unique request identifier.
    */
    public func getParks() -> String {
        let identifier = "GetParks"
        self.sendDataRequest("GET", endpoint: "parks/active", type: .GetParks, identifier: identifier)
        return identifier
    }

    /**
    Request park details from appropriate API endpoint.
    
    - parameter parkId: Park identifier.
    
    - returns: Unique request identifier.
    */
    public func getPark(parkId: String) -> String {
        let identifier = parkId
        self.sendDataRequest("GET", endpoint: "park/\(parkId)", type: .GetPark, identifier: identifier)
        return identifier
    }
    
    /**
    Request park rides from appropriate API endpoint.
    
    - parameter parkId: Park identifier.
    
    - returns: Unique request identifier.
    */
    public func getParkRides(parkId: String) -> String {
        let identifier = parkId
        self.sendDataRequest("GET", endpoint: "park/\(parkId)/rides", type: .GetParkRides, identifier: identifier)
        return identifier
    }

    //MARK: Assets
    /**
    Request park assets from appropriate API endpoint.
    
    - parameter parkId: Park identifier.
    
    - returns: Unique request identifier.
    */
    public func getAssetsForPark(parkId: String) -> String {
        let identifier = parkId
        self.sendDataRequest("GET", endpoint: "assets/forPark/\(parkId)", type: .GetAssetsForPark, identifier: identifier)
        return identifier
    }
    
    //MARK: User requests
    /**
    Registers new Piscolve user.
    
    - parameter email:          User's email address.
    - parameter firstName:      User's first name.
    - parameter lastName:       User's last name.
    - parameter allowMarketing: Does user allow marketing?
    - parameter facebookId:     User's facebook Identifier.
    - parameter twitterId:      User's twitter Identifier.
    - parameter password:       User's new password.
    - parameter oldPassword:    USer's old passwork (in the case when it changes).
    */
    public func postUser(email: String, firstName: String, lastName: String, allowMarketing: Bool, facebookId: String? = nil, twitterId: String? = nil, password: String? = nil, oldPassword: String? = nil) {
        var params = ["email": email,
                      "firstName": firstName,
                      "lastName": lastName,
                      "allowMarketing": allowMarketing as AnyObject]
        
        if password != nil {
            params["password"] = password!
        }

        if oldPassword != nil {
            params["oldPassword"] = oldPassword!
        }
        
        if facebookId != nil {
            params["facebookId"] = facebookId!
        }
        
        if twitterId != nil {
            params["twitterId"] = twitterId!
        }
        
        self.sendDataRequest("POST", endpoint: "user", type: .PostUser, identifier: email, params: params)
    }
    
    /**
    Verifies if new user registration parameters are valid.
    
    - parameter email:          User's email address.
    - parameter password:       User's new password.
    - parameter firstName:      User's first name.
    - parameter lastName:       User's last name.
    - parameter allowMarketing: Does user allow marketing?
    
    - returns: Unique request identifier.
    */
    public func postUserValidation(email: String, password: String, firstName: String, lastName: String, allowMarketing: Bool) -> String {
        let identifier = email
        let params = ["email": email,
                      "password": password,
                      "firstName": firstName,
                      "lastName": lastName,
                      "allowMarketing": allowMarketing as AnyObject]
        
        
        self.sendDataRequest("POST", endpoint: "user/validate", type: .PostUserValidation, identifier: identifier, params: params)
        return identifier
    }

    /**
    Update existing Picsolve user.
    
    - parameter userId:         User identifier.
    - parameter email:          User's email address.
    - parameter firstName:      User's first name.
    - parameter lastName:       User's last name.
    - parameter allowMarketing: Does user allow marketing?
    - parameter facebookId:     User's facebook Identifier.
    - parameter twitterId:      User's twitter Identifier.
    - parameter password:       User's new password.
    - parameter oldPassword:    USer's old passwork (in the case when it changes).
    
    - returns: Unique request identifier.
    */
    public func putUser(userId: String, email: String, firstName: String, lastName: String, allowMarketing: Bool, facebookId: String? = nil, twitterId: String? = nil, password: String? = nil, oldPassword: String? = nil) -> String {
        let identifier = email
        var params = ["email": email,
            "firstName": firstName,
            "lastName": lastName,
            "allowMarketing": allowMarketing as AnyObject]
        
        if password != nil {
            params["password"] = password!
        }
        
        if oldPassword != nil {
            params["oldPassword"] = oldPassword!
        }
        
        if facebookId != nil {
            params["facebookId"] = facebookId!
        }
        
        if twitterId != nil {
            params["twitterId"] = twitterId!
        }
        
        self.sendDataRequest("PUT", endpoint: "user/\(userId)", type: .PutUser, identifier: identifier, params: params)
        return identifier
    }
    
    /**
    Forgot password API call.
    
    - parameter email: Picsolve user's email.

    - returns: Unique request identifier.
    */
    public func postForgotPassword(email: String) -> String {
        
        let identifier = email
        self.sendDataRequest("POST", endpoint: "user/forgotPassword", type: .PostForgotPassword, identifier: identifier)
        return identifier
    }
    
    /**
    Get user's details.
    
    - parameter userId: Picsolve user identifier.
    
    - returns: Unique request identifier.
    */
    public func getUser(userId: String) -> String {
        let identifier = userId
        self.sendDataRequest("GET", endpoint: "user/\(userId)", type: .GetUser, identifier: identifier)
        return identifier
    }
    
    /**
    Fetch global user achievements.
    
    - parameter userId: Picsolve user identifier.
    
    - returns: Unique request identifier.
    */
    public func getUserGlobalAchievements(userId: String) -> String {
        let identifier = userId
        self.sendDataRequest("GET", endpoint: "user/\(userId)/achievements/global", type: .GetUserGlobalAchievements, identifier: identifier)
        return identifier
    }
    
    /**
    Fetch user achievements for specific park.
    
    - parameter userId: Picsolve user identifier.
    - parameter parkId: Park identifier.
    
    - returns: Unique request identifier.
    */
    public func getUserAchievementsForPark(userId: String, parkId: String) -> String {
        let identifier = "\(userId)_\(parkId)"
        self.sendDataRequest("GET", endpoint: "user/\(userId)/park/\(parkId)/achievements", type: .GetUserAchievementsForPark, identifier: identifier)
        return identifier
    }
    
    /**
    Fetch the list of user days.
    
    - parameter userId:      Picsolve user identifier.
    - parameter ignoreCache: Force fetch - ignore locally cached response.
    
    - returns: Unique request identifier.
    */
    public func getUserDays(userId: String, ignoreCache: Bool = false) -> String {
        let identifier = userId
        self.sendDataRequest("GET", endpoint: "user/\(userId)/mydays", type: .GetUserDays, identifier: identifier, params: nil, ignoreCacheControl: ignoreCache)
        return identifier
    }
    
    /**
    Get user's MyDay details.
    
    - parameter userId:      Picsolve user identifier.
    - parameter date:        Date of the specific MyDay.
    - parameter parkId:      Park identifier.
    - parameter ignoreCache: Force fetch - ignore locally cached response.
    
    - returns: Unique request identifier.
    */
    public func getUserDay(userId: String, date: NSDate, parkId: String, ignoreCache: Bool = false) -> String {
        let identifier = "\(userId)_\(parkId)_\(date.timeIntervalSince1970)"
        
        if let dateString = dateToString(date, format:Constant.String.Date.Format, escapeSymbols: true)
        {
            self.sendDataRequest("GET", endpoint: "user/\(userId)/myday/\(dateString)/atPark/\(parkId)", type: .GetUserDay, identifier: identifier, params: nil, ignoreCacheControl: ignoreCache)
        }
        return identifier
    }
    
    //MARK: - User Media
    /**
    Associate media object with user by media Id.
    
    - parameter redemptionId: Identifier of the redemption from which media object has been taken.
    - parameter mediaId:      Media identifier.
    - parameter userId:       Picsolve user identifier.
    
    - returns: Unique request identifier.
    */
    public func putUsermediaById(redemptionId: String, mediaId: String, userId: String) -> String {
        self.sendDataRequest("PUT", endpoint: "usermedia/byId/\(mediaId)/intoUser/\(userId)", type: .PutUsermediaById, identifier: redemptionId)
        return redemptionId
    }

    /**
    Associate media object with user by media Code.
    
    - parameter redemptionId: Identifier of the redemption from which media object has been taken.
    - parameter mediaCode:    Media Code.
    - parameter userId:       Picsolve user identifier.
    
    - returns: Unique request identifier.
    */
    public func putUsermediaByCode(redemptionId: String, mediaCode: String, userId: String) -> String {
        self.sendDataRequest("PUT", endpoint: "usermedia/forCode/\(mediaCode)/intoUser/\(userId)", type: .PutUsermediaByCode, identifier: redemptionId)
        return redemptionId
    }
    
    //MARK: Achievements endpoints
    /**
    Fetch global achievements.
    
    - returns: Unique request identifier.
    */
    public func getGlobalAchievements() -> String {
        let identifier = "achievements/global"
        self.sendDataRequest("GET", endpoint: "achievements/global", type: .GetGlobalAchievements, identifier: identifier)
        return identifier
    }
    /**
    Fetch global achievements for Park.
    
    - parameter parkId: Unique park identifier.
    
    - returns: Unique request identifier.
    */
    public func getAchievementsForPark(parkId: String) -> String {
        let identifier = parkId
        self.sendDataRequest("GET", endpoint: "achievements/forPark/\(parkId)", type: .GetAchievementsForPark, identifier: identifier)
        return identifier
    }
    
    //MARK: Auth endpoints
    /**
    Login to Picsolve using email/password.
    
    - parameter email:    User's email.
    - parameter password: User's password.
    
    - returns: Unique request identifier.
    */
    public func postAuthLogin(email: String, password: String) -> String {
        let identifier = email
        let params = ["email": email,
            "password": password]
        
        self.sendDataRequest("POST", endpoint: "auth/login", type: .PostAuthLogin, identifier: identifier, params: params)
        return identifier
    }
    
    /**
    Login to Picsolve using Facebook token.
    
    - parameter email: User's email.
    - parameter token: Facebook token.
    
    - returns: Unique request identifier.
    */
    public func postAuthFacebook(email: String, token: String) -> String {
        let identifier = email
        let params = ["token": token]
        self.sendDataRequest("POST", endpoint: "auth/facebook", type: .PostAuthFacebook, identifier: identifier, params: params)
        return identifier
    }

    /**
    Logout form Piscolve.
    
    - parameter identifier: User identifier.
    
    - returns: Unique request identifier.
    */
    public func postAuthLogout(identifier: String) -> String {
        let params = Dictionary<String, String>()
        self.sendDataRequest("POST", endpoint: "auth/logout", type: .PostAuthLogout, identifier: identifier, params: params)
        return identifier
    }
    
    //MARK: Park media
    /**
    Redemption using 12 digit redemption code.
    
    - parameter redemptionCode: 12 digit redemption code.
    - parameter redemptionDate: Date when redemption is being made.
    
    - returns: Unique request identifier.
    */
    public func getParkmediaThumbnails(redemptionCode: String, redemptionDate: NSDate) -> String {
        let identifier = "\(redemptionCode)_\(Int64(redemptionDate.timeIntervalSince1970))"
        let date = Int64(redemptionDate.timeIntervalSince1970) * 1000 // "1441794931000" for test
        self.sendDataRequest("GET", endpoint: "parkmedia/thumbnails/at/\(date)/for/\(redemptionCode)", type: .GetParkmediaThumbnails, identifier: identifier)
        return identifier
    }
    
    /**
    Redemption usin QR code
    
    - parameter redemptionCode: QR code
    - parameter redemptionDate: Date when redemption is being made.
    
    - returns: Unique request identifier.
    */
    public func getParkmedia(redemptionCode: String, redemptionDate: NSDate) -> String {
        let identifier = "\(redemptionCode)_\(Int64(redemptionDate.timeIntervalSince1970))"
        self.sendDataRequest("GET", endpoint: "parkmedia/forCode/\(redemptionCode)", type: .GetParkmedia, identifier: identifier)
        return identifier
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
            //park

        default:
            logDebug("\(data)");
            return true
        }
    }
}
