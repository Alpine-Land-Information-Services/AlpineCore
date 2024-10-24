//
//  OptionalExtention.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 8/28/23.
//

import Foundation
import CoreData

public extension Optional where Wrapped == NSNumber {
    
    func toText() -> String {
        self != nil ? self == 1 ? "True" : "False" : "Not Set"
    }
}

public extension Optional where Wrapped == NSSet {
    
    func array<Object: NSManagedObject>(as objectType: Object.Type) -> [Object] {
        self?.allObjects as? [Object] ?? []
    }
}
