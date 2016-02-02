//
// RequestFactory.swift
//  PicPlay
//
//  Created by Aleksey Orlov on 6/15/15.
//  Copyright (c) 2015 Picsolve. All rights reserved.
//

import Foundation

class RequestFactory
{
    private static let baseUrl = "http://0.0.0.0/huge/"
//    private static let baseUrl = "https://us-cloud-api-ci.picsolve.net/"
    
    // Getting the API end point in debug mode
    #if DEBUG
    static func getEndpoint() -> NSString {
        return baseUrl
    }
    #endif
    
    /**
    Base function for creating all kinds of API requests.
    
    - parameter endpoint: Relative path to API endpoint.
    - parameter method:   HTTP method string, either "GET", "PUT", "POST" or "DELETE".
    - parameter eTag:     Caching tag. Please refer to https://devcenter.heroku.com/articles/ios-network-caching-http-headers for details.
    
    - returns: The newly created base request.
    */
    static func createBaseRequest(endpoint: String, method: String, eTag: String?) -> NSMutableURLRequest?
    {
        let urlString = "\(baseUrl)\(endpoint)"
        if let escapedString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()),
            url = NSURL(string: escapedString)
        {
            
            let baseRequest = NSMutableURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalCacheData , timeoutInterval: 60.0)
            
            baseRequest.HTTPMethod = method
            baseRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            if let eTagUnwrapped = eTag
            {
                baseRequest.setValue(eTagUnwrapped, forHTTPHeaderField: "If-None-Match")
            }
            
            return baseRequest
        }
        
        logError("Bad URL string: \(baseUrl)\(endpoint)")
        
        return nil
    }
    
    /**
    Create API data request. Request params are added to body.
    
    - parameter method:   HTTP method string, either "GET", "PUT", "POST".
    - parameter endpoint: Relative path to API endpoint.
    - parameter params:   Request parameters that are added to request body.
    - parameter eTag:     Caching tag. Please refer to https://devcenter.heroku.com/articles/ios-network-caching-http-headers for details.
    
    - returns: The newly created request.
    */
    static func dataRequestWithMethod(method: String, endpoint: String, params: Dictionary<String, AnyObject>? = nil, eTag: String? = nil) -> NSURLRequest?
    {
        if let request = RequestFactory.createBaseRequest(endpoint, method: method, eTag: eTag)
        {
            if let bodyParams = params,
                body = try? NSJSONSerialization.dataWithJSONObject(bodyParams, options: .PrettyPrinted)
            {
                request.addValue("\(body.length)", forHTTPHeaderField: "Content-Length")
                request.HTTPBody = body
            }
            
            return request;
        }
        
        return nil
    }

    /**
    Create API DELETE request.
    
    - parameter endpoint: Relative path to API endpoint.
    
    - returns: The newly created request.
    */
    static func deleteRequestWithParams(endpoint: String) -> NSURLRequest?
    {
        return RequestFactory.createBaseRequest(endpoint, method: "DELETE", eTag: nil)
    }

    /**
    Create download request.
    
    - parameter urlString: The absolute url to the data being downloaded.
    
    - returns: The newly created download request.
    */
    static func downloadRequestWithParams(urlString: String) -> NSURLRequest?
    {
        if let url = NSURL(string: urlString)
        {
            return NSURLRequest(URL: url)
        }
        
        return nil;
    }
}
