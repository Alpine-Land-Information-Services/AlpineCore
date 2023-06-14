//
//  Raw-NSManagedObject.swift
//  
//
//  Created by Jenya Lebid on 5/25/23.
//

import CoreData

public extension NSManagedObject { //MARK: Fetch
    
    static func getCount(using predicate: NSPredicate?, in context: NSManagedObjectContext) throws -> Int {
        let request = NSFetchRequest<Self>(entityName: Self.entityName)
        request.predicate = predicate
        return try context.count(for: request)
    }
    
    static func batchDelete(using predicate: NSPredicate?, in context: NSManagedObjectContext) throws {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: Self.entityName)
        fetch.predicate = predicate
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        try context.execute(request)
        context.refreshAllObjects()
    }
}
