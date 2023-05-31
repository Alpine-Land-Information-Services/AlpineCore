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
    
    func persistentSave() throws {
        try self.performAndWait {
            try self.save()
            var parentContext = self.parent
            while let parent = parentContext {
                try parent.performAndWait {
                    try parent.save()
                }
                parentContext = parent.parent
            }
        }
    }
}
