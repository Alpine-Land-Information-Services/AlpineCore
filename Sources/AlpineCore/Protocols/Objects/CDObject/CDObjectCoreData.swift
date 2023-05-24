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
        return try Self.find(by: predicate, in: context) as? Object
    }
    
    static func deleteAllLocal(in context: NSManagedObjectContext) throws {
        let predicate = NSPredicate(format: "a_deleted = TRUE AND a_syncDate = nil")
        let objects = try Self.findMultiple(by: predicate, in: context)

        for object in objects {
            context.delete(object)
        }
    }
}

public extension CDObject {
    
    static func getNotExportedCount(in context: NSManagedObjectContext) async throws -> [UUID] {
        let predicate = NSPredicate(format: "a_changed = TRUE")
        guard let objects = try await Self.findObjects(by: predicate, in: context) as? [Self] else {
            return []
        }
        
        return objects.compactMap({$0.guid})
    }
}

public extension CDObject {
    
    func trash(_ value: Bool) throws {
        try managedObjectContext?.performAndWait {
            setValue(true, forKey: "a_changed")
            setValue(value, forKey: "a_deleted")
            try managedObjectContext?.forceSave()
        }
    }
    
    func isLocalDeleted() throws -> Bool {
        guard let context = managedObjectContext else {
            return false
        }
        
        return context.performAndWait {
            if value(forKey: "a_deleted") as! Bool && value(forKey: "a_syncDate") == nil {
                context.delete(self)
                return true
            }
            return false
        }
    }
}
