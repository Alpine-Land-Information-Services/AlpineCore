//
//  Raw-NSManagedObject.swift
//  
//
//  Created by Jenya Lebid on 5/25/23.
//

import CoreData

public extension NSManagedObject { //MARK: Fetch
    
    enum CDError: Error {
        case noBatchDeleteResults
    }
    
    static func getCount(using predicate: NSPredicate?, in context: NSManagedObjectContext) throws -> Int {
        let request = NSFetchRequest<Self>(entityName: Self.entityName)
        request.predicate = predicate
        return try context.count(for: request)
    }
    
    static func batchDelete(using predicate: NSPredicate?, refreshContext: Bool = false, in context: NSManagedObjectContext) throws {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: Self.entityName)
        fetch.predicate = predicate
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        try context.execute(request)
        if refreshContext {
            context.refreshAllObjects()
        }
    }
    
    static func batchDelete(for predicate: NSPredicate?, in context: NSManagedObjectContext, update updateContext: NSManagedObjectContext? = nil) throws {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: Self.entityName)
        fetch.predicate = predicate
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        request.resultType = .resultTypeObjectIDs
        let result = try context.execute(request) as? NSBatchDeleteResult
        
        if let updateContext {
            guard let objectIDArray = result?.result as? [NSManagedObjectID] else {
                throw CDError.noBatchDeleteResults
            }
            for id in objectIDArray {
                updateContext.delete(updateContext.object(with: id))
            }
        }
    }
}
