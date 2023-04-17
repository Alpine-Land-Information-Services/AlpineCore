//
//  StorageDB.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/17/23.
//

import CoreData

public class StorageDB: Database, CDStack {
    
    public static var shared: Database = StorageDB()

    public static var identifier = "AlpineCore"
    public static var model = "AppStorage"
    
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

        
    public var moc: NSManagedObjectContext
    public var poc: NSManagedObjectContext

    init () {
        self.moc = Self.persitentContainer.viewContext
        self.poc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.moc.parent = poc
    }
}
