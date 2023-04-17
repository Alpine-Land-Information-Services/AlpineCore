//
//  NSManagedObject.swift
//  AlpineCore
//
//  Created by mkv on 5/9/22.
//

import CoreData

extension NSManagedObject: Nameable {}

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
            print("Failure to save context: \(error)")
        }
    }
    
    func inContext(_ context: NSManagedObjectContext) -> Self? {
        self.managedObjectContext?.performAndWait {
            return try? context.existingObject(with: self.objectID) as? Self
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
            print("Failure to delete object: \(error)")
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
    
    static func findObject(for entity: String? = nil, by predicate: NSPredicate, in context: NSManagedObjectContext) -> NSManagedObject? {
        let request = NSFetchRequest<NSManagedObject>(entityName: entity ?? Self.entityName)
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        var result: NSManagedObject?
        context.performAndWait {
            do {
                result = try context.fetch(request).first
            } catch {
                print(error)
            }
        }
        return result
    }
}
