//
//  File.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 10/21/24.
//

import Foundation
import SwiftData

public extension ModelContext {
    
    func find<Model: PersistentModel>(by predicate: Predicate<Model>) throws -> Model? {
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        
        return try self.fetch(descriptor).first
    }
    
    func search<Model: PersistentModel>(with predicate: Predicate<Model>) throws -> [Model] {
        let descriptor = FetchDescriptor(predicate: predicate)
        return try self.fetch(descriptor)
    }
}
