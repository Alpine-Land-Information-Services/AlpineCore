//
//  Database.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 3/30/23.
//

import Foundation
import CoreData

public protocol Database {
    
    static var shared: Database { get set }
    
    var moc: NSManagedObjectContext { get }
    var poc: NSManagedObjectContext { get }
}

public extension Database {

    static var main: NSManagedObjectContext {
        Self.shared.moc
    }
    
    static var background: NSManagedObjectContext {
        Self.shared.poc
    }
}
