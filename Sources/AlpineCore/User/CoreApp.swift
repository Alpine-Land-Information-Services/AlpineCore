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
    
    public var uiAlignmnet: String = "trailing"
    public var buttonsSize = "compact"
    
    @Transient
    public var sync: () -> Void = {}
    
    @Transient
    public var tutorialObjectFetcher: (() -> (NSManagedObject?, NSManagedObject?))!
    
    @Relationship(deleteRule: .cascade)
    public var ui: CoreAppUI?
    @Relationship(deleteRule: .cascade)
    public var tips: CoreTips?
    
    public var inTutorial = true
    
    public init(_ name: String, version: String?) {
        self.name = name
        self.version = version
        
        ui = CoreAppUI()
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

public extension CoreApp {
    
    var panelAlignment: Alignment {
        get {
            switch uiAlignmnet {
            case "trailing":
                return .trailing
            default:
                return .leading
            }
        }
        set {
            switch newValue {
            case .trailing:
                uiAlignmnet = "trailing"
            default:
                uiAlignmnet = "leading"
            }
        }
    }
    
    var largeButtons: Bool {
        buttonsSize == "large"
    }
    
    var leftUI: Bool {
        uiAlignmnet == "trailing"
    }
}


