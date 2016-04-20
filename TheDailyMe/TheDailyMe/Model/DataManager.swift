//
// DataManager.swift
//  PicPlay
//
//  Created by Anton Barbasevich on 6/11/15.
//  Copyright (c) 2015 Picsolve. All rights reserved.
//

import Foundation
import CoreData

public class DataManager: NSObject, NSFetchedResultsControllerDelegate {
    
    private var model: NSManagedObjectModel
    private var context: NSManagedObjectContext
    private var coordinator: NSPersistentStoreCoordinator
    private var fetchResult: NSFetchedResultsController? = nil
    
    static let fileManager = NSFileManager.defaultManager()
    
    
    public var user: User? = nil
    public static let sharedInstance = DataManager()
    
    /**
    Initializes Data manager.
    */
    override init() {
        
        let dataURL: NSURL = DataManager.fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent("TheDailyMe.sqlite")
        
        let options: [NSObject: AnyObject] = [NSMigratePersistentStoresAutomaticallyOption : true,
            NSInferMappingModelAutomaticallyOption : true,
            NSSQLitePragmasOption : ["journal_mode" : "DELETE"]]

        let url: NSURL = NSBundle.mainBundle().URLForResource("TheDailyMe", withExtension: "momd")!

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
        
        super.init()
        self.setCoreUser()
        self.initUserFetch()
    }
    
    public func initUserFetch() {
        self.fetchResult = self.userController(self)
    }
    
    public func setCoreUser() {
        if let email = self.userEmail() as? String {
            self.user = self.fetchEntity("User", withFieldKey: "email", withFieldValue: email) as? User
        }
        else {
            let email = "empty"
            self.setUserEmail(email)
            self.user = self.setUser(nil, email: email, birthDate: nil, firstName: nil, lastName: nil, password: nil, avatarImage: nil)
        }
    }
    
    public func userEmail() -> AnyObject? {
        return NSUserDefaults.standardUserDefaults().objectForKey(Constant.String.UserEmailKey)
    }
    
    public func setUserEmail(email: String) {
        NSUserDefaults.standardUserDefaults().setObject(email, forKey: Constant.String.UserEmailKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        self.initUserFetch()
    }
    
    public func isAuthorised() -> Bool {
        return self.user?.id != nil && self.user?.id?.intValue != 0
    }
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.setCoreUser()
    }
    
    // MARK: - Fetch Methods
    /**
    Fetches entity from local database.
    
    - parameter entityName: Name of entity.
    - parameter identifier: Identifier of entity.
    
    - returns: Fetched entity or nil if it doesn't exist.
    */
    public func fetchEntity(entityName: String, withID identifier: Int64) -> AnyObject? {

        return fetchEntity(entityName, withFieldKey: "id", withFieldValue: NSNumber.init(longLong: identifier))
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
        
        var predicate: NSPredicate? = nil
        if value.isKindOfClass(NSData) {
            predicate = NSPredicate(format: "%K = %@", key, value as! NSData)
        }
        else if value.isKindOfClass(NSNumber) {
            predicate = NSPredicate(format: "%K = %@", key, value as! NSNumber)
        }
        else if value.isKindOfClass(NSDate) {
            predicate = NSPredicate(format: "%K = %@", key, value as! NSDate)
        }
        else {
            predicate = NSPredicate(format: "%K = %@", key, value as! String)
        }
        
        
        fetchRequest.entity = entity
        fetchRequest.predicate = predicate
        
        let entities: NSArray = try! self.context.executeFetchRequest(fetchRequest)
        
        if entities.count > 0 {
            return entities.firstObject
        }
        
        return nil
    }
    
    public func fetchEntities(entityName: String, predicate: NSPredicate?) -> [AnyObject]? {
        let fetchRequest: NSFetchRequest = NSFetchRequest()
        let entity: NSEntityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: self.context)!
        
        fetchRequest.entity = entity
        fetchRequest.predicate = predicate
        
        let entities: NSArray = try! self.context.executeFetchRequest(fetchRequest)
        
        if entities.count > 0 {
            return entities as [AnyObject]
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
            let predicate: NSPredicate? = NSPredicate(format: "ANY %K.id = %@", relativeEntityName!, relativeID!)
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
    
    public func fetchQuestionForDate(date: NSDate = NSDate()) -> Question? {
        
        var question : Question? = nil
        let objects = self.fetchEntities("Question", predicate: predicateForDayFromDate(date, key: "assignedDate"))
        if (objects != nil) {
            question = objects?.first as? Question
        }
        
        return question
    }
    
    public func fetchRecordForQuestion(question: Question, user: User) -> Record? {
        var record : Record? = nil
        let objects = self.fetchEntities("Record", predicate: NSPredicate(format: "user == %@ AND question == %@", argumentArray: [user, question]))
        if (objects != nil) {
            record = objects?.first as? Record
        }
        
        return record
    }
    
    public func fetchRecordForDate(date: NSDate = NSDate()) -> Record? {
        
        var record : Record? = nil
        
        let objects = self.fetchEntities("Record", predicate: predicateForDayFromDate(date, key: "date"))
        if (objects != nil) {
            record = objects?.first as? Record
        }
        
        return record
    }
    
    public func fetchQuestionsInMonthForDate(date: NSDate = NSDate())->[Question]? {
        var questions: [Question]? = nil
        let objects = fetchEntities("Question", predicate: predicateForMonthFromDate(date, key: "assignedDate"))
        if (objects != nil) {
            questions = objects as? [Question]
            questions!.sortInPlace({ $0.assignedDate?.timeIntervalSinceNow < $1.assignedDate?.timeIntervalSinceNow })
        }
        
        return questions
    }
   
    // MARK: - Create Methods
    /**
    Create entity.
    
    - parameter entityName: Name of entity.
    - parameter identifier: Identifier of entity.
    
    - returns: Newly created entity or nil if it is not found.
    */
    public func createEntity(entityName: String, withID identifier: Int64) -> AnyObject? {
        var object: AnyObject? = self.fetchEntity(entityName, withID: identifier)
        
        if object == nil {
            object = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: self.context)

            if (object?.respondsToSelector(Selector("setId")) != nil) {
                object?.setValue(NSNumber.init(longLong: identifier), forKey: "id")
            }
        }
        
        return object
    }
    
    

    
    public func setUser(id: NSNumber?,
        email: String,
        birthDate: NSDate?,
        firstName: String?,
        lastName: String?,
        password: String?,
        avatarImage: NSData?) -> User?
    {
        var object: User? = self.fetchEntity("User", withFieldKey: "email", withFieldValue: email) as? User
        if object == nil {
            object = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: self.context) as? User
        }
        object?.email = email
        
        if id != nil {
            object?.id = id
        }
        if firstName != nil {
            object?.firstName = firstName
        }
        if lastName != nil {
            object?.lastName = lastName
        }
        if birthDate != nil {
            object?.birthDate = birthDate
        }
        if password != nil {
            object?.password = password
        }
        if avatarImage != nil {
            object?.avatarImage = avatarImage
        }
        
        self.saveContext()
        
        return object
    }
    
    public func setQuestion(id: NSNumber, text: String, assignDate: NSDate) -> Question?
    {
        var question: Question? = self.fetchEntity("Question", withFieldKey: "id", withFieldValue: id) as? Question
        if question == nil {
            question = (NSEntityDescription.insertNewObjectForEntityForName("Question", inManagedObjectContext: self.context) as! Question)
            question!.id = id
        }
        question?.text = text
        question?.assignedDate = assignDate
        
        self.saveContext()
        
        return question
    }
    
    
    public func setRecord(record: Record?,
        id: NSNumber?,
        user: User?,
        answer: String,
        note: String?,
        date: NSDate?,
        question: Question) -> Record?
    {
        var recordObj : Record? = record
        //attempt to locate
        if recordObj == nil {
            recordObj = (id != nil) ? self.fetchEntity("Record", withFieldKey: "id", withFieldValue: id!) as? Record : nil
        }
        //attempt to create
        if recordObj == nil {
            recordObj = (NSEntityDescription.insertNewObjectForEntityForName("Record", inManagedObjectContext: self.context) as! Record)
            recordObj!.id = id
        }
        recordObj?.answer = answer
        if id != nil {
            recordObj?.id = id
        }
        if user != nil {
            recordObj?.user = user
        }
        if note != nil {
            recordObj?.note = note
        }
        if let dateObj = date {
            recordObj?.date = dateObj
        }
        else {
            recordObj?.date = NSDate()
        }
        
        recordObj?.question = question
        
        self.saveContext()
        
        return recordObj
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
    public func deleteEntity(entityName: String, withID identifier: Int64) -> Bool {
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
    public func fetchResultControllerWithEntityName(entityName: String, predicate: NSPredicate?, sortDescriptor: NSSortDescriptor, sectionNameKeyPath: String?, cacheFile: String?, delegate: NSFetchedResultsControllerDelegate?) -> NSFetchedResultsController? {
        let fetchRequest: NSFetchRequest = NSFetchRequest()
        let entity: NSEntityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: self.context)!
        
        fetchRequest.entity = entity
        
        if predicate != nil {
            fetchRequest.predicate = predicate
        }
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let controller: NSFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheFile)
        controller.delegate = delegate
        do {
            try controller.performFetch()
        } catch let error as NSError {
            logError("Cannot initialize FerchResultsController error: \(error.localizedDescription),\n\(error.userInfo) ]")
            //abort()
        }
        
        return controller
    }
    
    /**
    Create fetch results controller for user data.
    
    - returns: Fetch results controller for the user or nil.
    */
    public func userController(delegate : NSFetchedResultsControllerDelegate) -> NSFetchedResultsController? {
        let predicate = NSPredicate(format: "%K = %@", "email", self.userEmail() as! String)
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "id", ascending: true, selector: #selector(NSNumber.compare(_:)))
        let userController: NSFetchedResultsController? = self.fetchResultControllerWithEntityName("User",
            predicate: predicate,
            sortDescriptor: sortDescriptor,
            sectionNameKeyPath: nil,
            cacheFile: nil,
            delegate: delegate)
        
        return userController
    }
 
    public func questionsController() -> NSFetchedResultsController? {
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "id", ascending: true, selector: #selector(NSNumber.compare(_:)))
        let questionController: NSFetchedResultsController? = self.fetchResultControllerWithEntityName("Question", predicate: nil, sortDescriptor: sortDescriptor, sectionNameKeyPath: nil, cacheFile: nil, delegate: nil)
        
        return questionController
    }
    
    public func recordController(questionId: String) -> NSFetchedResultsController? {
        let predicate = NSPredicate(format: "question.id = \(questionId)")
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "id", ascending: true, selector: #selector(NSNumber.compare(_:)))
        
        return self.fetchResultControllerWithEntityName("Record", predicate: predicate, sortDescriptor: sortDescriptor, sectionNameKeyPath: nil, cacheFile: nil, delegate: nil)
    }
}
