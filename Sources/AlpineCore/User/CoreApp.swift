//
//  CoreApp.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 2/1/24.
//

import SwiftUI
import SwiftData
import CoreData

@Model
public class CoreApp {

    public var isInitialized = false
    
    public var name: String
    public var version: String?
    
    @Transient
    public var sync: () -> Void = {}
    @Transient
    public var tutorialObjectFetcher: (() -> (NSManagedObject?, NSManagedObject?))!
    @Transient
    public var tutorialObjectRemover: () -> Void = {}
    
    @Relationship(deleteRule: .cascade)
    public var ui: CoreAppUI
    @Relationship(deleteRule: .cascade)
    public var tips: CoreTips
    
    public var inTutorial = true
    public var isSandbox = false
    
    public init(_ name: String, version: String?, isSandbox: Bool = false) {
        self.name = name
        self.version = version
        self.isSandbox = isSandbox
        
        ui = CoreAppUI()
        tips = CoreTips()
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


