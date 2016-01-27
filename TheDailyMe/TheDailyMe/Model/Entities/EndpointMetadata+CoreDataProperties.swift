//
//  EndpointMetadata+CoreDataProperties.swift
//  TheDailyMe
//
//  Created by Vlad Antipin on 1/27/16.
//  Copyright © 2016 TheDailyMe. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension EndpointMetadata {

    @NSManaged var eTag: String?
    @NSManaged var identifier: String?
    @NSManaged var nextUpdateDate: NSDate?
    @NSManaged var requestIdentifier: String?
    @NSManaged var requestType: NSNumber?

}
