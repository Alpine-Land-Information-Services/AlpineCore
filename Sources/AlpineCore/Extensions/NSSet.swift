//
//  NSSet.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/19/23.
//

import CoreData

public extension Optional where Wrapped == NSSet {
    
    func array<Object: NSManagedObject>(as objectType: Object.Type) -> [Object] {
        self?.allObjects as? [Object] ?? []
    }
}
