//
//  NSManagedObject+JSON.swift
//  PicPlay
//
//  Created by Anton Barbasevich on 6/25/15.
//  Copyright (c) 2015 Picsolve. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    /**
    Update CoreData entity properties with values form dictionary.
    
    - parameter keyedValues: Dictionary with the new propeties value.
    
    - returns: True if entity has been updated, false otherwise.
    */
    func safeSetValuesForKeysWithDictionary(keyedValues: Dictionary<String, AnyObject>) -> Bool {
        
        var needSaveContext = false
        let attributes = self.entity.attributesByName
        
        for attribute in attributes.keys {
            
            if let unwrappedValue: AnyObject = keyedValues[attribute ] {
                
                var newValue: AnyObject = unwrappedValue
                let attributeType = (attributes[attribute])!.attributeType
                
                if (attributeType == .DateAttributeType) && newValue.isKindOfClass(NSString) {
                  
                    if let newDate = dateFromString(newValue as! String, format:Constant.String.Date.FormatWithTimezone) {
                        newValue = newDate
                    }
                    else if let newDate = dateFromString(newValue as! String, format:Constant.String.Date.Format) {
                        newValue = newDate
                    }
                }
                
                var valueChanges = true
                
                if let oldValue: AnyObject = self.valueForKey(attribute ) {
                    
                    if ((attributeType == .StringAttributeType) &&
                        newValue.isKindOfClass(NSString) &&
                        oldValue.isEqualToString(newValue as! String)) {
                        
                        valueChanges = false
                    } else if (((attributeType == .Integer16AttributeType) ||
                                (attributeType == .Integer32AttributeType) ||
                                (attributeType == .Integer64AttributeType) ||
                                (attributeType == .BooleanAttributeType) ||
                                (attributeType == .DoubleAttributeType)) &&
                                newValue.isKindOfClass(NSNumber) &&
                                oldValue.isEqualToNumber(newValue as! NSNumber)) {
                        
                        valueChanges = false
                    } else if ((attributeType == .DateAttributeType) &&
                        newValue.isKindOfClass(NSDate) &&
                        oldValue.isEqualToDate(newValue as! NSDate)) {
                        
                        valueChanges = false
                    }
                }
                
                if valueChanges {
                    
                    self.setValue(newValue, forKey: attribute )
                    needSaveContext = true
                }
                
            }
            
        }
        
        return needSaveContext
    }
}
