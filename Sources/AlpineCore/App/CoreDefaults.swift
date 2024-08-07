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
    
    public func resetWithCode(_ code: String) {
        data = Self.makeData()
        resetCode = code
        UserDefaults().synchronize()
    }
}

public extension CoreDefaults {
    
    var lastAppLaunch: Date? {
        get {
            value(for: "last_app_launch") as? Date
        }
        set {
            setValue(newValue, for: "last_app_launch")
        }
    }
    
//    var isAppActive: Bool {
//        get {
//            value(for: "is_app_active") as? Bool ?? false
//        }
//        set {
//            setValue(newValue, for: "is_app_active")
//        }
//    }
    
    var layerReinit: Bool {
        get {
            value(for: "layer_reinit") as? Bool ?? false
        }
        set {
            setValue(newValue, for: "layer_reinit")
        }
    }
    
    var isInitialized: Bool {
        get {
            value(for: "is_initialized") as? Bool ?? false
        }
        set {
            setValue(newValue, for: "is_initialized")
        }
    }
    
    var isSandboxInitialized: Bool {
        get {
            value(for: "is_sandbox_initialized") as? Bool ?? false
        }
        set {
            setValue(newValue, for: "is_sandbox_initialized")
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
    
    var jwtToken: Data? {
        get {
            value(for: "jwt_token") as? Data

        }
        set {
            setValue(newValue, for: "jwt_token")
        }
    }
    
    var resetCode: String? {
        get {
            value(for: "reset_code") as? String

        }
        set {
            setValue(newValue, for: "reset_code")
        }
    }
}
