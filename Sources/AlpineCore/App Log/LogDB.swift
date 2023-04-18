//
//  LogDB.swift
//  
//
//  Created by Jenya Lebid on 4/17/23.
//

import CoreData

class LogDB: Database {

    static var shared: Database = LogDB()
    
    var container: NSPersistentContainer
    var moc: NSManagedObjectContext
    var poc: NSManagedObjectContext
    
    init() {
        self.container = LogCDStack.persitentContainer
        self.moc = self.container.viewContext
        self.poc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.poc.parent = self.moc
    }
}

class LogCDStack: CDStack {
    
    static var model = "AppLog"
    static var identifier: String? = nil
    
    static var storeDescription: NSPersistentStoreDescription?
    static var persitentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: model, managedObjectModel: managedObjectModel)

        container.loadPersistentStores { (description, error) in
            storeDescription = description
            description.shouldMigrateStoreAutomatically = false
            if let error = error {
                fatalError()
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()
}
