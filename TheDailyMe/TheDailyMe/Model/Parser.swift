//
// Parser.swift
//  PicPlay
//
//  Created by Anton Barbasevich on 6/25/15.
//  Copyright (c) 2015 Picsolve. All rights reserved.
//

import UIKit
import CoreData

public class Parser: NSObject {
   
    /**
    Update entity prperies wit the data in dictionary.
    
    - parameter entity:     Entity being updated.
    - parameter properties: Dictionary with new property values.
    - parameter save:       Save changes in persistence chnages.
    
    - returns: true if entity has been updated, false otherwise.
    */
    public class func updateEntity(entity: NSManagedObject, withProperties properties:Dictionary<String, AnyObject>, saveContext save: Bool) -> Bool {
        
        let updated = entity.safeSetValuesForKeysWithDictionary(properties)
        if updated && save
        {
            return DataManager.sharedInstance.saveContext()
        }
        
        return updated
    }
    
    /**
    Create entities based on array of dictionaries with properties.
    
    - parameter entityName: Entity name.
    - parameter data:       Array with dictionarues of entitie's properties.
    
    - returns: Array of newly creates entities.
    */
    class func parseEntitiesName(entityName: String, data: [Dictionary<String, AnyObject>]) -> Set<NSManagedObject> {
        
        var entities: Set<NSManagedObject> = []
        
        for itemRAW in data {
            
            if let identifier = itemRAW["id"] as? String,
                item = DataManager.sharedInstance.createEntity(entityName, withID: identifier) as? NSManagedObject
            {
                
               Parser.updateEntity(item, withProperties: itemRAW, saveContext: false)
                
                entities.insert(item)
            }
        }
        
        return entities
    }

}
