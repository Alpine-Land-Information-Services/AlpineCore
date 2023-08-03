//
//  NSManagedObjectContext.swift
//  AlpineCore
//
//  Created by mkv on 4/12/23.
//

import CoreData

public extension NSManagedObjectContext {
    
    func easySave() {
        do {
            if self.hasChanges {
                try self.save()
            }
        } catch {
            assertionFailure("Failure to save context: \(error)")
        }
    }
    
    func saveChanges() throws {
        try performAndWait {
            if hasChanges {
                try save()
            }
        }
    }
    
    func persistentSave() throws {
        try performAndWait {
            try save()
            var parentContext = parent
            while let parent = parentContext {
                try parent.performAndWait {
                    try parent.save()
                }
                parentContext = parent.parent
            }
        }
    }
    
    func safeRefresh() {
        performAndWait {
            refreshAllObjects()
        }
    }
}
