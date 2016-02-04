//
//  Question+CoreDataProperties.swift
//  TheDailyMe
//
//  Created by Vlad Antipin on 2/4/16.
//  Copyright © 2016 TheDailyMe. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Question {

    @NSManaged var id: NSNumber?
    @NSManaged var text: String?
    @NSManaged var record: NSSet?

}
