//
// CoreNetworkManager.swift
//  PicPlay
//
//  Created by Aleksey Orlov on 6/15/15.
//  Copyright (c) 2015 Picsolve. All rights reserved.
//

import Foundation
import UIKit

public class WeakHolder {
    weak var value : AnyObject?
    init (value: AnyObject) {
        self.value = value
    }
}

public class CoreNetworkManager: NSObject, NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate
{
    public var tasksBeingExecuted = Dictionary<String, NSData>()
    public var subscribers = Array<WeakHolder>()
    public var session: NSURLSession!
    var online: Bool
  
    var active: Bool = false {
        didSet {
             UIApplication.sharedApplication().networkActivityIndicatorVisible = active
        }
    }
    
    public override init() {
        self.online = true
        super.init()
    }

    //MARK: Public methods
    /**
    Register new subscriber. Subscribers will be notified when status of any request cnages.
    
    - parameter subscriber: A subscriber being registered.
    */
    public func subscribe(subscriber:NetworkDelegate) {
        
        for existing in self.subscribers {
            if let strongSubscriber = existing.value as?NetworkDelegate {
                if strongSubscriber.identifier == subscriber.identifier {
                    return
                }
            }
        }
        
        self.subscribers.append(WeakHolder(value: subscriber))
    }
    
    /**
    Unregister a subscriber.
    
    - parameter subscriber: A subscriber being unregistered.
    */
    public func unsubscribe(subscriber:NetworkDelegate) {
        var index = 0
        
        for existing in self.subscribers {
            if let strongSubscriber = existing.value as?NetworkDelegate {
                if strongSubscriber.identifier == subscriber.identifier {
                    self.subscribers.removeAtIndex(index)
                    break
                }
            }
            index++
        }
    }
    
    
    /**
    Create and sends data request. If request result is cached, function will not send request.
    
    - parameter method:             HTTP method string, either "GET", "PUT", "POST" or "DELETE"
    - parameter endpoint:           Relative path to API endpoint.
    - parameter type:               Type of the request. SeeRequestType enumeration for possible values.
    - parameter identifier:         Request unique identifier.
    - parameter params:             Request parameters that are added to request body.
    - parameter ignoreCacheControl: Ignore local cache for this request.
    */
    public func sendDataRequest(method: String, endpoint: String, type:RequestType, identifier: String, params: Dictionary<String, AnyObject>? = nil, ignoreCacheControl: Bool = false) {
        
        if (!self.online) {
            self.notifySubscribersRequestFailed(type, requestIdentifier: identifier, httpCode: nil, customCode: .OfflineError)
        }
        else {
            let medatadaIdentifier = "type=\(type.rawValue), identifier=\(identifier)"
            let cacheMedatada = DataManager.sharedInstance.fetchEntity("EndpointMetadata", withID: medatadaIdentifier) as?EndpointMetadata
            
            if cacheMedatada != nil && !ignoreCacheControl && cacheMedatada!.nextUpdateDate!.compare(NSDate()) == .OrderedDescending {
                self.notifySubscribersRequestProcessed(type, requestIdentifier: identifier)
            }
            else {
                let eTag: String? = cacheMedatada == nil ? nil : cacheMedatada!.eTag
                let request = RequestFactory.dataRequestWithMethod(method, endpoint: endpoint, params: params, eTag: eTag)
                let taskId = NetworkHelper.taskIdFrom(type, requestIdentifier: identifier)
                
                //check if taks is being executed now
                if (request != nil && self.tasksBeingExecuted[taskId] == nil) {
                    self.tasksBeingExecuted[taskId] = NSData()
                    self.initializeSession()
                    
                    let task = self.session.dataTaskWithRequest(request!)
                    
                    task.taskDescription = taskId
                    task.resume()
                    
                    //logging
                    if let httpBody = request!.HTTPBody {
                        var bodyStr = "";
                        if (httpBody.length > 5000) {
                            bodyStr = "<\(httpBody.length / 1024) kBytes of data>"
                        }
                        else if let bodyStrUnwrapped = NSString(data: httpBody, encoding:NSUTF8StringEncoding) as? String {
                            bodyStr = bodyStrUnwrapped;
                        }
                        
                        logDebug("\(request!.HTTPMethod) -> \(request!.URL?.absoluteString)\n type:\(type.rawValue), identifier:\(identifier), JSON:\n \(bodyStr)")
                    }
                    else {
                        logDebug("\(request!.HTTPMethod) -> \(request!.URL?.absoluteString)\n type:\(type.rawValue), identifier:\(identifier)")
                    }
                }
            }
        }
        
        self.active = self.tasksBeingExecuted.count > 0
    }
    
    /**
    Create and sends download request. If request result is cached, function will not send request.
    
    - parameter url:                Absolute url to the data being downloaded.
    - parameter ignoreCacheControl: Ignore local cache for this request.
    */
    public func sendDownloadRequest(url: String, ignoreCacheControl: Bool = false) {
        let type:RequestType = .DownloadFile
        
        if (!self.online) {
            self.notifySubscribersRequestFailed(type, requestIdentifier: url, httpCode: nil, customCode: .OfflineError)
        }
        else {
            let medatadaIdentifier = "type=\(type.rawValue), identifier=\(url)"
            let cacheMedatada = DataManager.sharedInstance.fetchEntity("EndpointMetadata", withID: medatadaIdentifier) as?EndpointMetadata
            
            if cacheMedatada != nil && !ignoreCacheControl && cacheMedatada!.nextUpdateDate!.compare(NSDate()) == .OrderedDescending {
                self.notifySubscribersRequestProcessed(type, requestIdentifier: url)
            }
            else {
                let request = RequestFactory.downloadRequestWithParams(url)
                let taskId = NetworkHelper.taskIdFrom(type, requestIdentifier: url)
                
                //check if taks is being executed now
                if (request != nil && self.tasksBeingExecuted[taskId] == nil) {
                    //check the cache first
                    self.tasksBeingExecuted[taskId] = NSData()
                    self.initializeSession()
                    
                    let task = self.session.downloadTaskWithRequest(request!)
                    task.taskDescription = taskId
                    task.resume()
                }
            }
        }
        
        self.active = self.tasksBeingExecuted.count > 0
    }
    
    //MARK: Virtual methods
    func getCustomErrorCode(data: Dictionary<String, AnyObject>) ->ErrorCode {
        return .Success
    }
    
    func processResponseData(requestType:RequestType, requestIdentifier: String, data: Dictionary<String, AnyObject>) -> Bool {
        return true
    }
    
    //MARK: Cache control
    func updateMetadata(response: NSURLResponse?, requestType:RequestType, requestIdentifier: String){
    }
    
    //MARK: Private methods
    /**
    Create and initializes NSURL session.
    */
    public func initializeSession() {
        if (self.session == nil) {
            let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
            sessionConfiguration.HTTPMaximumConnectionsPerHost = 20
            self.session = NSURLSession(configuration: sessionConfiguration, delegate:self, delegateQueue:nil)
        }
    }
    
    /**
    Callback function which is called when download request is completed.
    
    - parameter task:              The instance of NSURLSessionDownloadTask for download request.
    - parameter requestIdentifier: Request unique identifier.
    - parameter httpCode:          HTTP response code.
    */
    private func downloadTaskCompleted(task: NSURLSessionDownloadTask, requestIdentifier: String, httpCode: Int) {
        if NetworkHelper.isHttpCodeSuccessful(httpCode) {
            logDebug("SUCCESS <=  \(requestIdentifier)")
            self.notifySubscribersRequestProcessed(.DownloadFile, requestIdentifier: requestIdentifier)
        }
        else {
            //check if response content is JSON
            var customCode:ErrorCode? = nil
            
            if let data = self.tasksBeingExecuted[task.taskDescription!],
                responseData = NetworkHelper.parseResponseData(data) {
                customCode = self.getCustomErrorCode(responseData)
            }
            
            logError("HTTP ERRROR <=  \(requestIdentifier) type:\(RequestType.DownloadFile), httpCode=\(httpCode), customCode=\(customCode)")
            self.notifySubscribersRequestFailed(.DownloadFile, requestIdentifier: requestIdentifier, httpCode: httpCode, customCode: customCode)
        }
    }
    
    /**
    Callback function which is called when data request is completed.
    
    - parameter task:               The instance of NSURLSessionDataTask for data request.
    - parameter responseUrl:        Absolute response url.
    - parameter requestIdentifier:  Request unique identifier.
    - parameter httpCode:           HTTP response code.
    */
    public func dataTaskCompleted(task: NSURLSessionDataTask, responseUrl: String, requestType:RequestType, requestIdentifier: String, httpCode: Int) {
        if let data = self.tasksBeingExecuted[task.taskDescription!] {
            if let parsedData = NetworkHelper.parseResponseData(data) {
                if NetworkHelper.isHttpCodeSuccessful(httpCode) {
                    dispatch_async(dispatch_get_main_queue(),{
                        if self.processResponseData(requestType, requestIdentifier: requestIdentifier, data: parsedData) {
                            logDebug("SUCCESS <- \(responseUrl)\n type:\(requestType.rawValue), identifier:\(requestIdentifier), JSON:\n \(parsedData)")
                            self.notifySubscribersRequestProcessed(requestType, requestIdentifier: requestIdentifier)
                        }
                        else {
                            logError("ERROR APPLYING RESPONSE DATA <- \(responseUrl)\n type:\(requestType.rawValue), identifier:\(requestIdentifier), JSON:\n \(parsedData)")
                            self.notifySubscribersRequestFailed(requestType, requestIdentifier: requestIdentifier, httpCode: httpCode, customCode: .ResponseApplyingError)
                        }
                    })
                }
                else {
                    let customCode = self.getCustomErrorCode(parsedData)
                    logError("HTTP ERROR <- \(responseUrl)\n type:\(requestType.rawValue), identifier:\(requestIdentifier), httpCode=\(httpCode), JSON:\n \(parsedData)")
                    self.notifySubscribersRequestFailed(requestType, requestIdentifier: requestIdentifier, httpCode: httpCode, customCode: customCode)
                }
            }
            else if let bodyStrUnwrapped = NSString(data: data, encoding:NSUTF8StringEncoding) as? String {
                logError("ERROR PARSING RESPONSE DATA <- \(responseUrl)\n type:\(requestType.rawValue), identifier:\(requestIdentifier), Raw data:\n \(bodyStrUnwrapped)")
                self.notifySubscribersRequestFailed(requestType, requestIdentifier: requestIdentifier, httpCode: httpCode, customCode: .ResponseParsingError)
            }
            else {
                logError("ERROR PARSING RESPONSE DATA <- \(responseUrl)\n type:\(requestType.rawValue), identifier:\(requestIdentifier)")
                self.notifySubscribersRequestFailed(requestType, requestIdentifier: requestIdentifier, httpCode: httpCode, customCode: .ResponseParsingError)
            }
        }
    }
    
    /**
    Notifies observers if request is completed successfully.
    
    - parameter requestType:       Type of the request. SeeRequestType enumeration for possible values.
    - parameter requestIdentifier: Request unique identifier.
    */
    public func notifySubscribersRequestProcessed(requestType:RequestType, requestIdentifier: String) {
        dispatch_async(dispatch_get_main_queue()) {
            //reversive iteration, Business Logic will be notified last
            for weakSubscriber in Array(self.subscribers.reverse()) {
                if let strongSubscriber = weakSubscriber.value as?NetworkDelegate {
                    strongSubscriber.requestProcessed(requestType, identifier: requestIdentifier)
                }
            }
        }
    }
    
    /**
    Notifies observers if request is completed with error.
    
    - parameter requestType:       Type of the request. SeeRequestType enumeration for possible values.
    - parameter requestIdentifier: Request unique identifier.
    - parameter httpCode:          HTTP response code.
    - parameter customCode:        Custom error code retrieved from response data. SeeErrorCode enumeration for possible values.
    */
    public func notifySubscribersRequestFailed(requestType:RequestType, requestIdentifier: String, httpCode: Int?, customCode:ErrorCode?) {
        dispatch_async(dispatch_get_main_queue()) {
            //reversive iteration, Business Logic will be notified last
            for weakSubscriber in Array(self.subscribers.reverse()) {
                if let strongSubscriber = weakSubscriber.value as?NetworkDelegate {
                    strongSubscriber.requestFailed(requestType, identifier: requestIdentifier, httpCode: httpCode, customCode: customCode)
                }
            }
        }
    }
    
    /**
    Notifies observers about the progress.
    
    - parameter requestType:       Type of the request. SeeRequestType enumeration for possible values.
    - parameter requestIdentifier: Request unique identifier.
    - parameter value:             The value of the progress [0.0 - 1.0].
    */
    public func notifySubscribersRequestProgress(requestType:RequestType, requestIdentifier: String, value: Float) {
        dispatch_async(dispatch_get_main_queue()) {
                //reversive iteration, Business Logic will be notified last
                for weakSubscriber in Array(self.subscribers.reverse()) {
                    if let strongSubscriber = weakSubscriber.value as?NetworkDelegate {
                        strongSubscriber.requestProgress(requestType, identifier: requestIdentifier, value: value)
                    }
                }
        }
    }
    
    //MARK: NSURLSessionTaskDelegate
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        let (requestType, requestIdentifier) = NetworkHelper.requestTypeAndIdentifierFrom(task)
        
        if let httpResponse = task.response as? NSHTTPURLResponse,
            responseUrl = httpResponse.URL?.absoluteString
        {
            if let nonoptionalError = error {
                logError("FRAMEWORK ERRROR <-  \(responseUrl) type:\(requestType.rawValue), code=\(nonoptionalError.code), message=\(nonoptionalError.localizedDescription)")
                self.notifySubscribersRequestFailed(requestType, requestIdentifier: requestIdentifier, httpCode: nil, customCode: .FrameworkError)
            }
            else if httpResponse.statusCode == 304 {
                //special handling for 'Not Modified' case
                dispatch_async(dispatch_get_main_queue()) {
                    self.updateMetadata(task.response, requestType: requestType, requestIdentifier: requestIdentifier)
                    logError("NOT MODIFIED ON SERVER <-  \(responseUrl) type:\(requestType.rawValue), identifier:\(requestIdentifier)")
                }
                
                self.notifySubscribersRequestProcessed(requestType, requestIdentifier: requestIdentifier)
            }
            else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.updateMetadata(task.response, requestType: requestType, requestIdentifier: requestIdentifier)
                }
                
                if (task is NSURLSessionDataTask) {
                    self.dataTaskCompleted(task as! NSURLSessionDataTask, responseUrl: responseUrl, requestType: requestType, requestIdentifier: requestIdentifier, httpCode: httpResponse.statusCode)
                }
                else if (task is NSURLSessionDownloadTask) {
                    self.downloadTaskCompleted(task as! NSURLSessionDownloadTask, requestIdentifier: requestIdentifier, httpCode: httpResponse.statusCode)
                }
            }
            
            //remove task from dictionary
            dispatch_async(dispatch_get_main_queue()) {
                
                self.tasksBeingExecuted.removeValueForKey(task.taskDescription!)
                self.active = self.tasksBeingExecuted.count > 0
            }
        }
    }
    
    //MARK: NSURLSessionDataDelegate
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        let rawData = NSMutableData(data: self.tasksBeingExecuted[dataTask.taskDescription!]!)
        rawData.appendData(data)
        self.tasksBeingExecuted[dataTask.taskDescription!] = rawData
    }
    
    //MARK: NSURLSessionDownloadDelegate
    public func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {

    }
    
    public func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let (_, requestIdentifier) = NetworkHelper.requestTypeAndIdentifierFrom(downloadTask)
        var progress: Float = 0.0
        
        if totalBytesExpectedToWrite > 0 {
            progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        }
        
        self.notifySubscribersRequestProgress(.DownloadFile , requestIdentifier: requestIdentifier, value: progress)
    }
}