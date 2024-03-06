//
//  CoreDefaults.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 3/5/24.
//

import Foundation

@Observable
public class CoreDefaults {
        
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    static var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    static var key: String {
        "CORE"
    }
     
    static func makeData() -> [String: Any] {
        var data = [String: Any]()
        
        data["last_app_build"] = appBuild
        data["last_app_version"] = appVersion
        data["is_initialized"] = false

        data.saveToDefaults(key: key)
        return data
    }
    
    private var data: [String: Any]

    internal init() {
        data = Dictionary.getFromDefaults(key: Self.key) ?? Self.makeData()
    }
    
    public func save() {
        data.saveToDefaults(key: Self.key)
    }
    
    public func setValue(_ value: Any?, for key: String, doSave: Bool = true) {
        data[key] = value
        doSave ? save() : nil
    }
    
    public func value(for key: String) -> Any? {
        data[key]
    }
}

public extension CoreDefaults {
    
    var isInitialized: Bool {
        get {
            value(for: "is_initialized") as? Bool ?? false
        }
        set {
            setValue(newValue, for: "is_initialized")
        }
    }
    
    var appBuild: String? {
        get {
            value(for: "last_app_build") as? String
        }
        set {
            setValue(newValue, for: "last_app_build")
        }
    }
    
    var appVersion: String? {
        get {
            value(for: "last_app_version") as? String
        }
        set {
            setValue(newValue, for: "last_app_version")
        }
    }
    
    var lastUser: String? {
        get {
            value(for: "last_user") as? String

        }
        set {
            setValue(newValue, for: "last_user")
        }
    }
    
    var backyardToken: Data? {
        get {
            value(for: "backyard_token") as? Data

        }
        set {
            setValue(newValue, for: "backyard_token")
        }
    }
}
