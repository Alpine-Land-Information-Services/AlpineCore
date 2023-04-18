//
//  StorageDB.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/17/23.
//

import CoreData

public class StorageDB: Database {
    
    public static var shared: Database = StorageDB()
    
    public var container: NSPersistentContainer
    public var moc: NSManagedObjectContext
    public var poc: NSManagedObjectContext

    init () {
        self.container = StorageStack.persitentContainer
        self.moc = self.container.viewContext
        self.poc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.poc.parent = moc
    }
}

class StorageStack: CDStack {
    
    public static var model = "AppStorage"
    static var identifier: String? = nil
    
    public static var storeDescription: NSPersistentStoreDescription?
    public static var persitentContainer: NSPersistentContainer = {
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
