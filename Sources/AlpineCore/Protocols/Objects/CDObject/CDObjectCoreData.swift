//
//  CDObjectCoreData.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 5/22/23.
//

import CoreData

public extension CDObject {
    
    static func find<Object: CDObject>(by id: UUID, in context: NSManagedObjectContext) throws -> Object? {
        let predicate = NSPredicate(format: "a_guid = %@", id as CVarArg)
        return try Object.find(by: predicate, in: context)
    }
}

public extension CDObject {
    
    func trash() throws {
        try managedObjectContext?.performAndWait {
            setValue(true, forKey: "a_deleted")
            try managedObjectContext?.forceSave()
        }
    }
}
