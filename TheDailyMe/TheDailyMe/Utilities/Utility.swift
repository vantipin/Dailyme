//
// Utility.swift
//  PicPlay
//
//  Created by Aleksey Orlov on 6/15/15.
//  Copyright (c) 2015 Picsolve. All rights reserved.
//

import Foundation
import UIKit

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
public func dateFromString(string: String, format: String = "yyyy-MM-dd") -> NSDate?
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
func dateToString(date: NSDate, format: String = "yyyy-MM-dd", escapeSymbols: Bool = false) -> String?
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


func predicateForDayFromDate(date: NSDate, key: String) -> NSPredicate {
    let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    let components = calendar!.components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: date)
    components.hour = 00
    components.minute = 00
    components.second = 00
    let startDate = calendar!.dateFromComponents(components)
    components.hour = 23
    components.minute = 59
    components.second = 59
    let endDate = calendar!.dateFromComponents(components)
    
    return NSPredicate(format: "\(key) >= %@ AND \(key) =< %@", argumentArray: [startDate!, endDate!])
}

func predicateForMonthFromDate(date: NSDate, key: String) -> NSPredicate {
    let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    //let components = calendar!.components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: date)
    let components = calendar!.components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: date)
    components.hour = 00
    components.minute = 00
    components.second = 00
    components.day = 1
    let startOfMonth = calendar!.dateFromComponents(components)!
    
    let comps2 = NSDateComponents()
    comps2.hour = 23
    comps2.minute = 59
    comps2.second = 59
    comps2.month = 1
    comps2.day = -1
    let endOfMonth = calendar!.dateByAddingComponents(comps2, toDate: startOfMonth, options: [])!
    
    return NSPredicate(format: "\(key) >= %@ AND \(key) =< %@", argumentArray: [startOfMonth, endOfMonth])
}

func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage? {
    
    let contextImage: UIImage = UIImage(CGImage: image.CGImage!)
    
    let contextSize: CGSize = contextImage.size
    
    var posX: CGFloat = 0.0
    var posY: CGFloat = 0.0
    var cgwidth: CGFloat = CGFloat(width)
    var cgheight: CGFloat = CGFloat(height)
    
    // See what size is longer and create the center off of that
    if contextSize.width > contextSize.height {
        posX = ((contextSize.width - contextSize.height) / 2)
        posY = 0
        cgwidth = contextSize.height
        cgheight = contextSize.height
    } else {
        posX = 0
        posY = ((contextSize.height - contextSize.width) / 2)
        cgwidth = contextSize.width
        cgheight = contextSize.width
    }
    
    let rect: CGRect = CGRectMake(posX, posY, cgwidth, cgheight)
    
    // Create bitmap image from context using the rect
    let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
    
    // Create a new image based on the imageRef and rotate back to the original orientation
    let image: UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
    
    return image
}



public func showAlert(text: String, inController: UIViewController) {
    let alertController = UIAlertController(title: text, message:
        nil, preferredStyle: UIAlertControllerStyle.Alert)
    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
    
    inController.presentViewController(alertController, animated: true, completion: nil)
}

