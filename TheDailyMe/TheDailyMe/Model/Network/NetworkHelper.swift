//
// NetworkHelper.swift
//  PicPlay
//
//  Created by Aleksey Orlov on 6/24/15.
//  Copyright (c) 2015 Picsolve. All rights reserved.
//

import Foundation

public class NetworkHelper
{
    static var deviceList: Dictionary <String, String>?

    /**
    Defines is HTTP response is successfull or not.
    
    - parameter httpCode: HTTP code.
    
    - returns:  true if response is successfull, false otherwise.
    */
    static func isHttpCodeSuccessful(httpCode: Int) -> Bool
    {
        return httpCode / 100 == 2
    }
    
    /**
    Create task identifier from request type and request identifier.
    
    - parameter requestType:       Request type.
    - parameter requestIdentifier: Request identifier.
    
    - returns: Task identifier.
    */
    public static func taskIdFrom(requestType:RequestType, requestIdentifier: String) -> String
    {
        return "\(requestType.rawValue), identifier=\(requestIdentifier)"
    }
    
    /**
    Retrieves request type and request identifier from session task.
    
    - parameter task: Session task description.
    
    - returns: Request type and request identifier.
    */
    static func requestTypeAndIdentifierFrom(task: NSURLSessionTask) -> (RequestType, String)
    {
        let components = task.taskDescription!.componentsSeparatedByString(", identifier=")
        
        if components.count == 2
        {
            if let intValue = Int(components[0]),
                type = RequestType(rawValue: intValue)
            {
                return (type, components[1])
            }
        }
        
        assert(true, "Cannot extract request type and identifier from taskDescription")
        return (.DownloadFile, "")
    }
    
    /**
    Create dictionary from contents of file.
    
    - parameter fileName: Name of a file.
    
    - returns: Dictionary with contents of file.
    */
    public static func dictionaryFromFile(fileName: String) -> AnyObject {
        
        if let path = NSBundle.mainBundle().pathForResource(fileName, ofType: ""),
            jsonData: AnyObject = try? NSData(contentsOfURL: NSURL(fileURLWithPath: path), options: NSDataReadingOptions.DataReadingMappedIfSafe) {
                
                if let json: AnyObject = try? NSJSONSerialization.JSONObjectWithData(jsonData as! NSData, options: NSJSONReadingOptions.MutableContainers) {
                    return json
                }
        }
        
        return Dictionary<String, AnyObject>()
    }
    
    /**
    Convers JSON content into a dictionary.
    
    - parameter rawData: Binary JSON content.
    
    - returns: Dictionary with contents of JSON data.
    */
    static func parseResponseData(rawData: NSData) -> Dictionary<String, AnyObject>?
    {
        if rawData.length > 0
        {
            // Parse JSON response.
            
            if let content: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(rawData, options: .MutableContainers)
            {
                if let dictionary = content as? Dictionary<String, AnyObject>
                {
                    return dictionary
                }
                else if let array = content as? Array<AnyObject>
                {
                    return ["result": array]
                }
            }
        }
        //TODO: JSON parser
        return Dictionary<String, AnyObject>()
    }


}
