//
//  Nameable.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/17/23.
//

import Foundation

public protocol Nameable {
    
    static var entityName: String { get }
//    static var displayName: String { get }
    
    var entityName: String { get }
//    var displayName: String { get }
}

public extension Nameable {
    
    static var entityName: String {
        String(describing: Self.self)
    }
    
//    static var displayName: String {
//        entityName
//    }
    
    var entityName: String {
        Self.entityName
    }
    
//    var displayName: String {
//        Self.displayName
//    }
}
