//
//  ExtensionVariables.swift
//  AlpineCore
//
//  Created by mkv on 9/6/24.
//

import Foundation

public protocol ExtensionVariables: AnyObject {
    
    var rawVarsStorage: [String: Any] { get set }
    func getVar(_ name: String) -> Any
    func setVar(_ name: String, value: Any)
}

public extension ExtensionVariables {
    
    func getVar(_ name: String) -> Any {
        rawVarsStorage[name]!
    }
    
    func setVar(_ name: String, value: Any) {
        rawVarsStorage[name] = value
    }
}
