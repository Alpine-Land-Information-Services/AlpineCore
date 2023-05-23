//
//  CDObject.swift
//  CDObject
//
//  Created by Jenya Lebid on 4/17/23.
//

import CoreData

public protocol CDObject where Self: NSManagedObject {
    
    var guid: UUID { get }
    
    static var displayName: String { get }
}

public extension CDObject {
    
    var guid: UUID {
        if let guid = (self.managedObjectContext?.performAndWait { value(forKey: "guid") as? UUID }) {
            return guid
        }
        
        assertionFailure("CDObject has no managedObjectContext!")
        return UUID(uuidString: "00000000-FA0E-0000-0000-000000000000")!
    }
    
    var deleted: Bool {
        managedObjectContext!.performAndWait {
            value(forKey: "a_deleted") as! Bool
        }
    }
    
    static var type: CDObject.Type {
        self as CDObject.Type
    }
    
    static func createObject(in context: NSManagedObjectContext) -> Self {
        return Self(entity: NSEntityDescription.entity(forEntityName: Self.entityName, in: context)!, insertInto: context)
    }
    
    static func clear(in context: NSManagedObjectContext) throws {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: Self.entityName)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        let deleteResult = try context.execute(request) as? NSBatchDeleteResult
         
        if let objectIDs = deleteResult?.result as? [NSManagedObjectID] {
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: objectIDs], into: [context])
        }
    }
    
    static func findCDObjects(by predicate: NSPredicate?, faults: Bool = false, in context: NSManagedObjectContext) -> [Self] {
        context.performAndWait {
            let request = NSFetchRequest<Self>(entityName: Self.entityName)
            if let predicate {
                request.predicate = predicate
            }
            request.returnsObjectsAsFaults = faults
            var result: [Self] = []
            
            do {
                result = try context.fetch(request)
            }
            catch {
                assertionFailure("CD FIND OBJECTS FAIL")
            }
            
            return result
        }
    }
    
    func printSelf() {
        print(" - object: \(self.entityDisplayName) ID: \(self.objectID.uriRepresentation().lastPathComponent) \(self.guid)")
    }
}
