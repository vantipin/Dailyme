//
//  Record+CoreDataProperties.swift
//  TheDailyMe
//
//  Created by Vlad Antipin on 4/20/16.
//  Copyright © 2016 TheDailyMe. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Record {

    @NSManaged var answer: String?
    @NSManaged var date: NSDate?
    @NSManaged var id: NSNumber?
    @NSManaged var note: String?
    @NSManaged var question: Question?
    @NSManaged var user: User?

}
