//
//  SFolder.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/17/23.
//

import CoreData

public extension SFolder {
    
    static func findOrCreate(for path: FSPath, in context: NSManagedObjectContext = StorageDB.main) -> SFolder {
        let predicate = NSPredicate(format: "path = %@", path.string)
        if let folder = SFolder.findObject(by: predicate, in: context) {
            _ = FS.findOrCreateDirectoryPath(for: path)
            return folder
        }
        
        return create(for: path, in: context)
    }
    
    
    static func create(for path: FSPath, in context: NSManagedObjectContext = StorageDB.main) -> SFolder {
        context.performAndWait {
            FS.recreateDirectory(at: path, isDirectory: true)
            let new = NSManagedObject(entity: NSEntityDescription.entity(forEntityName: SFolder.entityName, in: context)!, insertInto: context) as! SFolder
            new.guid = UUID()
            new.path = path.string
            
            new.save()
            
            return new
        }
    }
}

public extension SItem {
    
    var fsPath: FSPath {
        PathString(self.path!)
    }
}
