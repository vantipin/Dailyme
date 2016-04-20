//
//  User+CoreDataProperties.swift
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

extension User {

    @NSManaged var avatarImage: NSData?
    @NSManaged var birthDate: NSDate?
    @NSManaged var email: String?
    @NSManaged var firstName: String?
    @NSManaged var id: NSNumber?
    @NSManaged var lastName: String?
    @NSManaged var password: String?
    @NSManaged var records: NSSet?

}
