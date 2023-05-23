//
//  NSManagedObject.swift
//  AlpineCore
//
//  Created by mkv on 5/9/22.
//

import CoreData

extension NSManagedObject: Nameable {}

public extension NSManagedObject {
    
    func cdValue(for key: String) -> Any? {
        self.managedObjectContext?.performAndWait {
            return value(forKey: key)
        }
    }
}

public extension NSManagedObject {
    
    func save(in context: NSManagedObjectContext? = nil) {
        guard let context = context ?? self.managedObjectContext else {
            assertionFailure()
            return
        }
        do {
            if context.hasChanges {
                try context.save()
            }
        } catch {
            assertionFailure("Failure to save context: \(error)")
        }
    }
    
    func inContext(_ context: NSManagedObjectContext) -> Self? {
        self.managedObjectContext?.performAndWait {
            context.performAndWait {
                return try? context.existingObject(with: self.objectID) as? Self
            }
        }
    }
    
    func inContextAsync(_ context: NSManagedObjectContext) async -> Self? {
        await self.managedObjectContext?.perform {
            return try? context.existingObject(with: self.objectID) as? Self
        }
    }
    
    func delete(in context: NSManagedObjectContext? = nil, doSave: Bool = true) {
        guard let context = context ?? self.managedObjectContext else {
            assertionFailure()
            return
        }
        do {
            context.delete(self)
            if doSave {
                try context.save()
            }
        } catch {
            assertionFailure("Failure to delete object: \(error)")
        }
    }
    
    func saveMergeInTo(context: NSManagedObjectContext) {
        guard let selfContext = self.managedObjectContext else {
            assertionFailure()
            return
        }
        do {
            try selfContext.performAndWait {
                try selfContext.save()
                try context.performAndWait {
                    try context.save()
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
}

public extension NSManagedObject {
    
    static func mainAsyncSave(in context: NSManagedObjectContext) {
        DispatchQueue.main.async {
            do {
                try context.save()
            }
            catch {
                print("Could not save changed value:", error)
            }
        }
    }
    
    static func all(entityName: String? = nil, in context: NSManagedObjectContext) -> [NSManagedObject] {
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName ?? Self.entityName)
        request.returnsObjectsAsFaults = false
        var result: [NSManagedObject] = []
        context.performAndWait {
            do {
                result = try context.fetch(request)
            } catch {
                print(error)
            }
        }
        return result
    }
    
    static func disableAll(entityName: String? = nil, in context: NSManagedObjectContext) {
        do {
            for item in all(entityName: entityName, in: context) {
                item.setValue(false, forKey: "enabled_")
            }
            try context.save()
        } catch {
            print(error)
        }
    }
    
    static func findByGUID(entityName: String? = nil, _ guid: String?, in context: NSManagedObjectContext) -> Self? {
        guard guid != nil else { return nil }
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName ?? Self.entityName)
        request.predicate = NSPredicate(format: "guid = %@", UUID(uuidString: guid!)! as CVarArg)
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        var result: Self?
        context.performAndWait {
            do {
                result = try context.fetch(request).first as? Self
            } catch {
                print(error)
            }
        }
        return result
    }
    
    static func findByName(entityName: String? = nil,_ name: String, in context: NSManagedObjectContext) -> Self? {
        guard !name.isEmpty else { return nil }
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName ?? Self.entityName)
        request.predicate = NSPredicate(format: "name = %@", name)
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        var result: Self?
        context.performAndWait {
            do {
                result = try context.fetch(request).first as? Self
            } catch {
                print(error)
            }
        }
        return result
    }
    
    static func findPredicate(with predicate: NSPredicate, fetchLimit: Int, in context: NSManagedObjectContext) -> [NSManagedObject] {
        let request = NSFetchRequest<NSManagedObject>(entityName: Self.entityName)
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        request.fetchLimit = fetchLimit
        var result: [NSManagedObject] = []
        context.performAndWait {
            do {
                result = try context.fetch(request)
            } catch {
                print(error)
            }
        }
        return result
    }
    
    static func clearData(entityName: String? = nil, predicate: NSPredicate? = nil, in context: NSManagedObjectContext) {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName ?? Self.entityName)
        fetch.predicate = predicate
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        context.performAndWait {
            do {
                try context.execute(request)
            } catch {
                print(error)
            }
        }
    }
    
    static func deleteData(entityName: String? = nil, predicate: NSPredicate? = nil, in context: NSManagedObjectContext) {
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName ?? Self.entityName)
        request.predicate = predicate
        request.returnsObjectsAsFaults = true
        var objects: [NSManagedObject] = []
        context.performAndWait {
            do {
                objects = try context.fetch(request)
                for object in objects {
                    context.delete(object)
                }
            } catch {
                print(error)
            }
        }
    }
    
    static func count(entityName: String? = nil, predicate: NSPredicate? = nil, in context: NSManagedObjectContext) -> Int {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName ?? Self.entityName)
        request.predicate = predicate
        var result = 0
        request.returnsObjectsAsFaults = true
        context.performAndWait {
            do {
                result = try context.fetch(request).count
            } catch {
                print(error)
            }
        }
        return result
    }
    
    static func hasAnyEntities(entityName: String? = nil, in context: NSManagedObjectContext) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName ?? Self.entityName)
        var result = false
        request.fetchLimit = 1
        request.returnsObjectsAsFaults = true
        context.performAndWait {
            do {
                result = try context.fetch(request).count > 0
            } catch {
                print(error)
            }
        }
        return result
    }
    
    static func findObjects(by predicate: NSPredicate?, in context: NSManagedObjectContext) -> [NSManagedObject] {
        let request = NSFetchRequest<NSManagedObject>(entityName: Self.entityName)
        if let predicate {
            request.predicate = predicate
        }
        request.returnsObjectsAsFaults = false
        var result: [NSManagedObject] = []
        context.performAndWait {
            do {
                result = try context.fetch(request)
            } catch {
                print(error)
            }
        }
        return result
    }
    
    static func findObject(for entity: String? = nil, by predicate: NSPredicate, in context: NSManagedObjectContext) -> Self? {
        let request = NSFetchRequest<NSManagedObject>(entityName: entity ?? Self.entityName)
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        var result: Self?
        context.performAndWait {
            do {
                result = try context.fetch(request).first as? Self
            } catch {
                print(error)
            }
        }
        return result
    }
}

public extension NSManagedObject {
    
    static func find<Object: NSManagedObject>(by predicate: NSPredicate?, in context: NSManagedObjectContext) throws -> Object? {
        try context.performAndWait {
            let request = NSFetchRequest<Object>(entityName: Object.entityName)
            if let predicate {
                request.predicate = predicate
            }
            request.returnsObjectsAsFaults = false
            request.fetchLimit = 1
            
            return try context.fetch(request).first
        }
    }
    
        static func findMultiple<Object: NSManagedObject>(by predicate: NSPredicate?, in context: NSManagedObjectContext) throws -> [Object] {
            try context.performAndWait {
                let request = NSFetchRequest<Object>(entityName: String(describing: Object.self))
                if let predicate {
                    request.predicate = predicate
                }
                request.returnsObjectsAsFaults = false
                return try context.fetch(request)
            }
        }
    
    static func findMultiple(by predicate: NSPredicate?, in context: NSManagedObjectContext) throws -> [NSManagedObject] {
        try context.performAndWait {
            let request = NSFetchRequest<Self>(entityName: Self.entityName)
            if let predicate {
                request.predicate = predicate
            }
            request.returnsObjectsAsFaults = false
            return try context.fetch(request)
        }
    }
    
    static func findObjects<Object: NSManagedObject>(by predicate: NSPredicate?, in context: NSManagedObjectContext) async throws -> [Object] {
        try await context.perform {
            let request = NSFetchRequest<Object>(entityName: Object.entityName)
            if let predicate {
                request.predicate = predicate
            }
            request.returnsObjectsAsFaults = false
            return try context.fetch(request)
        }
    }
    
    static func findObjectIDs(by predicate: NSPredicate?, in context: NSManagedObjectContext) async throws -> [NSManagedObjectID] {
        return try await context.perform {
            let fetchRequest = NSFetchRequest<Self>(entityName: Self.entityName)
            fetchRequest.predicate = predicate
            fetchRequest.returnsObjectsAsFaults = false
            do {
                let fetchedObjects = try context.fetch(fetchRequest)
                let objectIDs = fetchedObjects.map { $0.objectID }
                return objectIDs
            } catch {
                throw error
            }
        }
    }
    
//    static func findObjects<Object: NSManagedObject>(by predicate: NSPredicate?, in context: NSManagedObjectContext) async throws -> [Object] {
//        return try await withCheckedThrowingContinuation { continuation in
//            context.perform {
//                do {
//                    let fetchRequest = NSFetchRequest<Object>(entityName: Object.entityName)
//                    fetchRequest.predicate = predicate
//                    
//                    let asyncFetchRequest = try NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { result in
//                        guard let entities = result.finalResult else {
//                            continuation.resume(throwing: NSError(domain: "entityFetch", code: 1, userInfo: nil))
//                            return
//                        }
//                        continuation.resume(returning: entities)
//                    }
//                    
//                    try context.execute(asyncFetchRequest)
//                } catch {
//                    continuation.resume(throwing: error)
//                }
//            }
//        }
//    }
}
