//
//  CDStack.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/17/23.
//

import CoreData

public protocol CDStack {
    
    var model: String { get }
    var identifier: String? { get }
    var managedObjectModel: NSManagedObjectModel { get }
    var storeDescription: NSPersistentStoreDescription? { get set }
    
    var containerName: String { get }
    var persistentContainer: NSPersistentContainer { get set }
}

public extension CDStack {
    
    var managedObjectModel: NSManagedObjectModel {
        if let identifier = identifier {
            let bundle = Bundle(identifier: identifier)
            let modelURL = bundle!.url(forResource: model, withExtension: "momd")!
            return NSManagedObjectModel(contentsOf: modelURL)!
        }

        let bundle = Bundle.module
        let modelURL = bundle.url(forResource: model, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }
    
    var containerURL: URL {
        var url = NSPersistentContainer.defaultDirectoryURL()
        url.appendPathComponent(containerName + ".sqlite")
        return url
    }
}
