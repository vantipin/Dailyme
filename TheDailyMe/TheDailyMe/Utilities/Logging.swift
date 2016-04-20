//
// Logging.swift
//  PicPlay
//
//  Created by Aleksey Orlov on 6/15/15.
//  Copyright (c) 2015 Picsolve. All rights reserved.
//

import Foundation

//#if DEBUG
    let LOGGING_DEBUG = true
    let LOGGING_ERROR = true
    let LOGGING_FUNCTION_NAME = true
//#else
//    let LOGGING_DEBUG = false
//    let LOGGING_ERROR = true
//    let LOGGING_FUNCTION_NAME = false
//#endif

/**
Debug Logging.

- parameter message:      Debug message.
- parameter functionName: The called function.
*/
func logDebug(message: String, functionName: String = #function)
{
    var removedOptionals = message.stringByReplacingOccurrencesOfString("Optional(\"", withString: "")
    removedOptionals = removedOptionals.stringByReplacingOccurrencesOfString("\")", withString: "")
    
    if LOGGING_DEBUG
    {
        if LOGGING_FUNCTION_NAME
        {
            print("\(NSDate()) DEBUG \(functionName): \(removedOptionals)\n", terminator: "")
        }
        else
        {
            print("\(NSDate()) DEBUG \(removedOptionals)\n", terminator: "")
        }
    }
}

/**
Error Logging.

- parameter message:      Error message.
- parameter functionName: The called function.
*/
func logError(message: String, functionName: String = #function)
{
    var removedOptionals = message.stringByReplacingOccurrencesOfString("Optional(\"", withString: "")
    removedOptionals = removedOptionals.stringByReplacingOccurrencesOfString("\")", withString: "")
    
    if LOGGING_ERROR
    {
        if LOGGING_FUNCTION_NAME
        {
            print("\(NSDate()) ERROR \(functionName): \(removedOptionals)\n", terminator: "")
        }
        else
        {
            print("\(NSDate()) ERROR \(removedOptionals)\n", terminator: "")
        }
    }
}

