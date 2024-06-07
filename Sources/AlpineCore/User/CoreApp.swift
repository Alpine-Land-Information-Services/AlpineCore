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
    
    @Relationship(deleteRule: .cascade, inverse: \CoreAppBackup.app)
    public var backups: [CoreAppBackup] = []
    
    public var inTutorial = true
    public var isSandbox = false
    
    public var parameters: [CoreAppParameter]?
    
    public init(_ name: String, version: String?, isSandbox: Bool = false) {
        self.name = name
        self.version = version
        self.isSandbox = isSandbox
        
        ui = CoreAppUI()
        tips = CoreTips()
    }
}

public extension CoreApp {
    
    func parameterValue<V: CoreParameterValueType>(for key: String, as valueType: V.Type) -> V? {
        guard let parameter = parameter(for: key) else {
            return nil
        }
        return V.value(from: parameter)
    }
    
    func setParameterValue<V: CoreParameterValueType>(_ value: V, for key: String) {
        let parameter = parameter(for: key) ?? CoreAppParameter(key: key)
        
        switch value {
        case let stringValue as String:
            parameter.strValue = stringValue
        case let intValue as Int:
            parameter.intValue = intValue
        case let codableValue as Codable:
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(codableValue) {
                parameter.dataValue = data
            }
        default:
            break
        }
    }
    
    
    func parameter(for key: String) -> CoreAppParameter? {
        parameters?.first(where: { $0.key == key })
    }
}

public extension CoreApp {
    
    var core: CoreAppControl {
        CoreAppControl.shared
    }
    
    var fullAppName: String {
        if let version {
            return name + " " + version
        }
        return name
    }
}


