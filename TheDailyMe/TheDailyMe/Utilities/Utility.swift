//
// Utility.swift
//  PicPlay
//
//  Created by Aleksey Orlov on 6/15/15.
//  Copyright (c) 2015 Picsolve. All rights reserved.
//

import Foundation

private let oldDevices : Set<String> = ["iPad",
                                "iPad1,1",
                                "iPhone1,1",
                                "iPhone1,2",
                                "iPhone2,1",
                                "iPhone3,1",
                                "iPhone3,2",
                                "iPhone3,3",
                                "iPod1,1",
                                "iPod2,1",
                                "iPod2,2",
                                "iPod3,1",
                                "iPod4,1",
                                "iPad2,1",
                                "iPad2,2",
                                "iPad2,3",
                                "iPad2,4",
                                "iPad3,1",
                                "iPad3,2",
                                "iPad3,3"]


/**
Get NSDate from String.

- parameter string: Source string.
- parameter format: Date format string.

- returns: Result NSDate.
*/
public func dateFromString(string: String, format: String = "yyyy-MM-ddTHH:mm:ss") -> NSDate?
{
    let dateFormatter = NSDateFormatter()
    dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    dateFormatter.dateFormat = format
    dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    return dateFormatter.dateFromString(string)
 }

/**
Get date String from NSDate.

- parameter date:          Source NSDate.
- parameter format:        Date format string.
- parameter escapeSymbols: Escape symbols.

- returns: Date String
*/
func dateToString(date: NSDate, format: String = "yyyy-MM-ddTHH:mm:ss", escapeSymbols: Bool = false) -> String?
{
    let dateFormatter = NSDateFormatter()
    dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    dateFormatter.dateFormat = format
    dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    var dateString: String? = dateFormatter.stringFromDate(date)
    
    if (dateString != nil && escapeSymbols)
    {
        dateString = dateString!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
    }
    
    return dateString
}

/**
Get user friendly date String from NSDate.

- parameter date: Source NSDate.

- returns: User friendly date String.
*/
func userFriendlyDateFormat(date: NSDate) -> String {
    
    let unitFlags: NSCalendarUnit = [.Year, .Month, .Day, .Hour, .Minute]
    
    var userFriedlyString: String! = nil
    
    let dateComponents = NSCalendar.currentCalendar().components(unitFlags, fromDate: date, toDate: NSDate(), options: NSCalendarOptions())
    
    if dateComponents.year > 0 {
        
        userFriedlyString = "\(dateComponents.year) year\(unitString(dateComponents.year)) ago"
    } else {
    
        if dateComponents.day > 0 {
            
            userFriedlyString = "\(dateComponents.day) day\(unitString(dateComponents.day)) ago"
        } else {
        
            if dateComponents.hour > 0 {
                
                userFriedlyString = "\(dateComponents.hour) hour\(unitString(dateComponents.hour)) ago"
            } else {
            
                if dateComponents.minute > 2 {
                    
                    userFriedlyString = "\(dateComponents.minute) minutes ago"
                } else {
                    
                    userFriedlyString = "Just now"
                }
            }
        }
    }
    
    return userFriedlyString
}

/**
The ending of word (singular and plural).

- parameter count: Count.

- returns: The ending of word.
*/
func unitString(count: Int) -> String {
    
    return count == 1 ? "" : "s"
}

