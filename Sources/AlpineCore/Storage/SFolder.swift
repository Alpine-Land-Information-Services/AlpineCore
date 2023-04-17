//
//  SFolder.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/17/23.
//

import CoreData

public extension SFolder {
    
    static func getOrCreateFolder(for path: String, in context: NSManagedObjectContext = StorageDB.main) -> SFolder {
        let predicate = NSPredicate(format: "path = %@", path)
        if let folder = SFolder.findObject(by: predicate, in: context) as? SFolder {
            return folder
        }
        
        return create(for: path, with: "")
    }
    
    
    static func create(for path: String, with name: String, in context: NSManagedObjectContext = StorageDB.main) -> SFolder {
        context.performAndWait {
            let new = NSManagedObject(entity: NSEntityDescription.entity(forEntityName: SFolder.entityName, in: context)!, insertInto: context) as! SFolder
            new.guid = UUID()
            new.path = path
            
            context.easySave()
            
            return new
        }
    }
}
