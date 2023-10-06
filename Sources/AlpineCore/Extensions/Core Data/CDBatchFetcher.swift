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

    public init(for entityName: String, using predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, with batchSize: Int, isModifying: Bool) {
        fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
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
