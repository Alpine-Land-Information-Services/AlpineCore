//
//  LogDB.swift
//  
//
//  Created by Jenya Lebid on 4/17/23.
//

import CoreData

class LogDB: Database, CDStack {

    static var shared: Database = LogDB()
    
    static var identifier = "AlpineCore"
    static var model = "AppLog"
    
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
    
    var moc: NSManagedObjectContext
    var poc: NSManagedObjectContext
    
    init() {
        self.moc = Self.persitentContainer.viewContext
        self.poc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.moc.parent = self.poc
    }
}
