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
    
    func forceSave() throws {
        try self.performAndWait {
            try self.save()
            while let parent = self.parent {
                try parent.save()
            }
        }
    }
}
