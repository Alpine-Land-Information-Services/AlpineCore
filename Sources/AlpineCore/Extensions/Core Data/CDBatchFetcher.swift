//
//  CDBatchFetcher.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 5/26/23.
//

import CoreData

public class CDBatchFetcher {

    private let fetchRequest: NSFetchRequest<NSManagedObject>

    private var currentBatch = 0
    private var isModifying: Bool

    public init(for entityName: String, using predicate: NSPredicate?, with batchSize: Int, isModifying: Bool) {
        fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = batchSize
        fetchRequest.fetchLimit = batchSize
        fetchRequest.returnsObjectsAsFaults = false
        
        self.isModifying = isModifying
    }

    public func fetchObjectBatch(in context: NSManagedObjectContext) throws -> [NSManagedObject]? {
        fetchRequest.fetchOffset = currentBatch * fetchRequest.fetchLimit

        let results = try context.fetch(fetchRequest)

        if !isModifying {
            currentBatch += 1
        }
        
        return results.isEmpty ? nil : results
    }
}


//public class CDBatchFetcher {
//
//    private let entityName: String
//    private let predicate: NSPredicate?
//    private let batchSize: Int
//    private var currentBatch = 0
//
//    public init(for entityName: String, using predicate: NSPredicate?, with batchSize: Int) {
//        self.entityName = entityName
//        self.predicate = predicate
//        self.batchSize = batchSize
//    }
//
//    public func fetchObjectBatch(in context: NSManagedObjectContext) throws -> [NSManagedObject]? {
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: self.entityName)
//        fetchRequest.predicate = self.predicate
//        fetchRequest.fetchLimit = self.batchSize
//        fetchRequest.fetchOffset = self.currentBatch * self.batchSize
//        fetchRequest.returnsObjectsAsFaults = false
//
//        let results = try context.fetch(fetchRequest)
//
//        if results.isEmpty {
//            return nil
//        } else {
//            self.currentBatch += 1
//            return results
//        }
//    }
//}






