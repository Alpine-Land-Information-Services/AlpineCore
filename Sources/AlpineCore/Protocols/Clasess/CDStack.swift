//
//  CDStack.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/17/23.
//

import CoreData

public protocol CDStack {
    
    static var identifier: String { get }
    static var model: String { get }
    
    static var managedObjectModel: NSManagedObjectModel { get }

    static var storeDescription: NSPersistentStoreDescription? { get set }
    static var persitentContainer: NSPersistentContainer { get set }
}

public extension CDStack {
    
    static var managedObjectModel: NSManagedObjectModel {
        let bundle = Bundle(identifier: identifier)
        let modelURL = bundle!.url(forResource: model, withExtension: "momd")!

        return NSManagedObjectModel(contentsOf: modelURL)!
    }
    
    static var newBackground: NSManagedObjectContext {
        Self.persitentContainer.newBackgroundContext()
    }
}
