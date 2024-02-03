//
//  CoreApp.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 2/1/24.
//

import SwiftData
import CoreData

@Model
public class CoreApp {

    public var isInitialized = false
    
    @Attribute(.unique)
    public var name: String
    public var version: String?
    
    @Transient
    public var sync: () -> Void = {}
    
    @Transient
    public var tutorialObjectFetcher: (() -> (NSManagedObject?, NSManagedObject?))!
    
    public var inTutorial = true
    
    public init(_ name: String, version: String?) {
        self.name = name
        self.version = version
    }
}

public extension CoreApp {
    
    var fullAppName: String {
        if let version {
            return name + " " + version
        }
        return name
    }
}


