//
// DataManager.swift
//  PicPlay
//
//  Created by Anton Barbasevich on 6/11/15.
//  Copyright (c) 2015 Picsolve. All rights reserved.
//

import Foundation
import CoreData

public class DataManager: NSObject {
    
    private var model: NSManagedObjectModel
    private var context: NSManagedObjectContext
    private var coordinator: NSPersistentStoreCoordinator
    
    static let fileManager = NSFileManager.defaultManager()
    
    public static let sharedInstance = DataManager()
    
    /**
    Initializes Data manager.
    */
    override init() {
        
        let dataURL: NSURL = DataManager.fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent("PicPlay.sqlite")
        
        let options: [NSObject: AnyObject] = [NSMigratePersistentStoresAutomaticallyOption : true,
            NSInferMappingModelAutomaticallyOption : true,
            NSSQLitePragmasOption : ["journal_mode" : "DELETE"]]

        let url: NSURL = NSBundle.mainBundle().URLForResource("PicPlay", withExtension: "momd")!

        self.model = NSManagedObjectModel(contentsOfURL: url)!
        self.coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        self.context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)

        var error: NSError?
        do {
            try self.coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: dataURL, options: options)
        } catch let error1 as NSError {
            error = error1
            logError("Database error: \(error!.localizedDescription),\n\(error!.userInfo)")
        }

        self.context.persistentStoreCoordinator = self.coordinator
        self.context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    }
    
    // MARK: - Fetch Methods
    /**
    Fetches entity from local database.
    
    - parameter entityName: Name of entity.
    - parameter identifier: Identifier of entity.
    
    - returns: Fetched entity or nil if it doesn't exist.
    */
    public func fetchEntity(entityName: String, withID identifier: String) -> AnyObject? {

        return fetchEntity(entityName, withFieldKey: "identifier", withFieldValue: identifier)
    }
    
    /**
    Fetches entity from local database by specific value by key.
    
    - parameter entityName: Name of entity.
    - parameter key:        Key of interest.
    - parameter value:      Value by the key.
    
    - returns: Fetched entity or nil if it doesn't exist.
    */
    public func fetchEntity(entityName: String, withFieldKey key: String, withFieldValue value: AnyObject) -> AnyObject? {
        
        let fetchRequest: NSFetchRequest = NSFetchRequest()
        let entity: NSEntityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: self.context)!
        let predicate: NSPredicate = NSPredicate(format: "%K = %@", key, value as! String)
        
        fetchRequest.entity = entity
        fetchRequest.predicate = predicate
        
        let entities: NSArray = try! self.context.executeFetchRequest(fetchRequest)
        
        if entities.count > 0 {
            return entities.firstObject
        }
        
        return nil
    }
    
    /**
    Fetch entities from local database by relative entity.
    
    - parameter entityName:         Name of entity.
    - parameter relativeEntityName: Name of relative entity.
    - parameter relativeID:         Identifier of relative entity.
    - parameter sortDescriptor:     Sort desctiptor.
    
    - returns: Array of entities.
    */
    public func fetchEntities(entityName:String, relativeEntityName:String?, relativeID:String?, sortDescriptor:NSSortDescriptor?) -> AnyObject? {
        
        if relativeEntityName != nil && relativeID != nil {
            let predicate: NSPredicate? = NSPredicate(format: "ANY %K.identifier = %@", relativeEntityName!, relativeID!)
            return fetchEntities(entityName, predicate: predicate, sortDescriptor: sortDescriptor)
        }
        
        return fetchEntities(entityName, predicate: nil, sortDescriptor: sortDescriptor)
    }
    
    /**
    Fetch entities from local database by predicate.
    
    - parameter entityName:     Name of entity
    - parameter predicate:      Pridecate.
    - parameter sortDescriptor: Sort descriptor.
    
    - returns: Array of entities or nil if no entities found.
    */
    public func fetchEntities(entityName:String, predicate: NSPredicate? , sortDescriptor:NSSortDescriptor?) -> AnyObject? {
        
        let fetchRequest: NSFetchRequest = NSFetchRequest()
        let entity: NSEntityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: self.context)!
        
        fetchRequest.entity = entity
        fetchRequest.predicate = predicate
        
        if sortDescriptor != nil {
            fetchRequest.sortDescriptors = [sortDescriptor!]
        }
        
        let entities: NSArray = try! self.context.executeFetchRequest(fetchRequest)
        
        if entities.count > 0 {
            return entities
        }
        
        return nil
    }
    
   
    // MARK: - Create Methods
    /**
    Create entity.
    
    - parameter entityName: Name of entity.
    - parameter identifier: Identifier of entity.
    
    - returns: Newly created entity or nil if it is not found.
    */
    public func createEntity(entityName: String, withID identifier: String) -> AnyObject? {
        var object: AnyObject? = self.fetchEntity(entityName, withID: identifier)
        
        if object == nil {
            object = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: self.context)

            if (object?.respondsToSelector(Selector("setIdentifier")) != nil) {
                object?.setValue(identifier, forKey: "identifier")
            }
        }
        
        return object
    }
    
    // MARK: - Delete Methods
    
    /**
    Delete entity.
    
    - parameter entity: Entity being deleted.
    */
    public func deleteEntity(entity: NSManagedObject) {
        self.context.deleteObject(entity)
    }
    
    /**
    Delete entity by name and identifier.
    
    - parameter entityName: Entity name.
    - parameter identifier: Entity identifier.
    
    - returns: True if entity was deleted, false otherwise.
    */
    public func deleteEntity(entityName: String, withID identifier: String) -> Bool {
        if let object = self.fetchEntity(entityName, withID: identifier) as? NSManagedObject {
            self.context.deleteObject(object)
            return true
        }
        
        return false
    }

    /**
    Delete entities by relative entity.
    
    - parameter entityName:         Entity name.
    - parameter relativeEntityName: Relative entity name.
    - parameter relativeID:         Relative entity identifier.
    - parameter sortDescriptor:     Sort descriptor.
    
    - returns: True if entity was deleted, false otherwise.
    */
    public func deleteEntities(entityName: String, relativeEntityName:String?, relativeID:String?, sortDescriptor:NSSortDescriptor?) -> Bool {
        if let objects = self.fetchEntities(entityName, relativeEntityName: nil, relativeID: nil, sortDescriptor: nil) as? [NSManagedObject] {
            for object in objects {
                self.context.deleteObject(object)
            }
        }
        
        return true
    }
    
    /**
    Delete user-specific data from database.
    
    - parameter userId: User identifier.
    */
    public func deleteUserData(userId: String) {
        self.deleteEntities("RidePicture", relativeEntityName: nil, relativeID: nil, sortDescriptor: nil)
        self.deleteEntities("UserPicture", relativeEntityName: nil, relativeID: nil, sortDescriptor: nil)
        self.deleteEntities("Achievement", relativeEntityName: "user.identifier", relativeID: userId, sortDescriptor: nil)
        
        self.deleteEntities("Album", relativeEntityName: nil, relativeID: nil, sortDescriptor: nil)
        self.deleteEntities("ParkmediaThumbnail", relativeEntityName: nil, relativeID: nil, sortDescriptor: nil)
        self.deleteEntities("Redemption", relativeEntityName: nil, relativeID: nil, sortDescriptor: nil)
     
        self.deleteEntities("EndpointMetadata", relativeEntityName: nil, relativeID: nil, sortDescriptor: nil)
        
        self.deleteEntity("User", withID: userId)
    }

    // MARK: - Save Methods
    /**
    Save changed in object content into persistent storage.
    
    - returns: True if changes are saved, false otherwise.
    */
    public func saveContext() -> Bool {
        var error: NSError?
        do {
            try self.context.save()
        } catch let error1 as NSError {
            error = error1
        }
        
        if error != nil {
            
            logError("Database error: \(error!.localizedDescription),\n\(error!.userInfo)")
            return false
        }
        
        return true
    }

    // MARK: - FetchResultsController Methods
    /**
    Create fetch result controller for entities by name and predicate.
    
    - parameter entityName:         Entity name.
    - parameter predicate:          Predicate.
    - parameter sortDescriptor:     Sort descriptor.
    - parameter sectionNameKeyPath: Key path for section names.
    
    - returns: Fetch result controller or nil.
    */
    public func fetchResultControllerWithEntityName(entityName: String, predicate: NSPredicate?, sortDescriptor: NSSortDescriptor, sectionNameKeyPath: String?) -> NSFetchedResultsController? {
        let fetchRequest: NSFetchRequest = NSFetchRequest()
        let entity: NSEntityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: self.context)!
        
        fetchRequest.entity = entity
        
        if predicate != nil {
            fetchRequest.predicate = predicate
        }
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let controller: NSFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        
        do {
            try controller.performFetch()
        } catch let error as NSError {
            logError("Cannot initialize FerchResultsController error: \(error.localizedDescription),\n\(error.userInfo) ]")
            //abort()
        }
        
        return controller
    }
    
    /**
    Create fetch results controller for parks.
    
    - returns: Fetch results controller for parks or nil.
    */
    public func parksController() -> NSFetchedResultsController? {
        
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "identifier", ascending: true, selector: Selector("localizedStandardCompare:"))
        let _ : NSPredicate = NSPredicate(format: "name!=nil AND name!=''")
        let parksController: NSFetchedResultsController? = self.fetchResultControllerWithEntityName("Park", predicate: nil, sortDescriptor: sortDescriptor, sectionNameKeyPath: nil)
        
        return parksController
    }
 
    /**
    Create fetch results controller for parks.
    
    - returns: Fetch results controller for parks or nil.
    */
    public func parkmediaThumbnailsController() -> NSFetchedResultsController? {
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "redemption.dateTime", ascending: false, selector: Selector("compare:"))
        
        let thumbnailsController: NSFetchedResultsController? = self.fetchResultControllerWithEntityName("ParkmediaThumbnail", predicate: nil, sortDescriptor: sortDescriptor, sectionNameKeyPath: "redemption.identifier")
        
        return thumbnailsController
    }
    
    /**
    Create user global achievements fetch controller.
    
    - parameter userId: User identifier.
    
    - returns: User global achievements controller or nil.
    */
    public func userGlobalAchievementsController(userId: String) -> NSFetchedResultsController? {
        let userPredicate = NSPredicate(format: "user.identifier == %@", userId)
        let noParkPredicate = NSPredicate(format: "park = nil")
        let predicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [userPredicate, noParkPredicate])
        let sortDescriptor = NSSortDescriptor(key: "identifier", ascending: true, selector: Selector("localizedStandardCompare:"))
        
        return self.fetchResultControllerWithEntityName("Achievement", predicate: predicate, sortDescriptor: sortDescriptor, sectionNameKeyPath: nil)
    }
    
    /**
    Create park achievements fetch controller.
    
    - parameter parkId: Park identifier.
    
    - returns: Park achievements controller or nil.
    */
    public func parkAchievementsController(parkId: String) -> NSFetchedResultsController? {
        let predicate = NSPredicate(format: "park.identifier == %@", parkId)
        let sortDescriptor = NSSortDescriptor(key: "identifier", ascending: true, selector: Selector("localizedStandardCompare:"))
        
        return self.fetchResultControllerWithEntityName("Achievement", predicate: predicate, sortDescriptor: sortDescriptor, sectionNameKeyPath: nil)
    }
    
    /**
    Create user achievements fetch controller.
    
    - parameter parkId: Park identifier.
    - parameter userId: User identifier.
    
    - returns: User achievements controller or nil.
    */
    public func userAchievementsController(parkId: String, userId: String) -> NSFetchedResultsController? {
        let parkIdPredicate = NSPredicate(format: "park.identifier == %@", parkId)
        let userIdPredicate = NSPredicate(format: "user.identifier == %@", userId)
        let predicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [parkIdPredicate, userIdPredicate])
        let sortDescriptor = NSSortDescriptor(key: "identifier", ascending: true, selector: Selector("localizedStandardCompare:"))
        
        return self.fetchResultControllerWithEntityName("Achievement", predicate: predicate, sortDescriptor: sortDescriptor, sectionNameKeyPath: nil)
    }
    
    /**
    Create global achievements fetch controller.
    
    - returns: Global achievements controller or nil.
    */
    public func globalAchievementsController() -> NSFetchedResultsController? {
        let noParkPredicate = NSPredicate(format: "park = nil")
        let noUserPredicate = NSPredicate(format: "user = nil")
        let predicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [noUserPredicate, noParkPredicate])
        let sortDescriptor = NSSortDescriptor(key: "identifier", ascending: true, selector: Selector("localizedStandardCompare:"))
        
        return self.fetchResultControllerWithEntityName("Achievement", predicate: predicate, sortDescriptor: sortDescriptor, sectionNameKeyPath: nil)
    }
    
    /**
    Create ride fetch controller for park.
    
    - parameter parkID: Park identifier.
    
    - returns: Ride controller or nil.
    */
    public func rideControllerWithParkID(parkID: String?) -> NSFetchedResultsController? {
        var predicate: NSPredicate? = nil
        
        if parkID != nil {
            predicate = NSPredicate(format: "park.identifier == %@", parkID!)
        }
        
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "identifier", ascending: true, selector: Selector("localizedStandardCompare:"))
        return self.fetchResultControllerWithEntityName("Ride", predicate: predicate, sortDescriptor: sortDescriptor, sectionNameKeyPath: nil)
    }
    
    /**
    Create albums fetch controller for specific user.
    
    - parameter userID: User identifier.
    
    - returns: Albums controller or nil.
    */
    public func albumsControllerWithUserID(userID: String) -> NSFetchedResultsController? {
        let predicate = NSPredicate(format: "user.identifier == %@", userID)
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "date", ascending: false, selector: Selector("compare:"))
        
        return self.fetchResultControllerWithEntityName("Album", predicate: predicate, sortDescriptor: sortDescriptor, sectionNameKeyPath: nil)
    }
    
    /**
    Create album idems fetch controller.
    
    - parameter albumID: Album identifier.
    
    - returns: Album idems fetch controller.
    */
    public func albumItemsControllerWithAlbumID(albumID: String) -> NSFetchedResultsController? {
        let predicate = NSPredicate(format: "album.identifier == %@", albumID)
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "date", ascending: false, selector: Selector("compare:"))
        
        return self.fetchResultControllerWithEntityName("AlbumItem", predicate: predicate, sortDescriptor: sortDescriptor, sectionNameKeyPath: nil)
    }
}
