//
//  CDStack.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/17/23.
//

import CoreData

public protocol CDStack {
    
    static var model: String { get }
    static var identifier: String? { get }
    static var managedObjectModel: NSManagedObjectModel { get }

    static var storeDescription: NSPersistentStoreDescription? { get set }
    static var persitentContainer: NSPersistentContainer { get set }
}

public extension CDStack {
    
    static var managedObjectModel: NSManagedObjectModel {
        if let identifier {
            let bundle = Bundle(identifier: identifier)
            let modelURL = bundle!.url(forResource: model, withExtension: "momd")!
            return NSManagedObjectModel(contentsOf: modelURL)!
        }

        let bundle = Bundle.module
        let modelURL = bundle.url(forResource: model, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }
}
