//
//  Nameable.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/17/23.
//

import Foundation

public protocol Nameable {
    
    static var entityName: String { get }
    static var entityDisplayName: String { get }
    
    var entityName: String { get }
    var entityDisplayName: String { get }
}

public extension Nameable {
    
    static var entityName: String {
        String(describing: Self.self)
    }
    
    static var entityDisplayName: String {
        entityName.separated
    }
    
    var entityName: String {
        Self.entityName
    }
    
    var entityDisplayName: String {
        Self.entityDisplayName
    }
}
