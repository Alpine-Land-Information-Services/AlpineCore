//
//  RawAttributeable.swift
//  AlpineCore
//
//  Created by mkv on 9/6/24.
//

import Foundation

public protocol RawAttributeable: AnyObject {
    
    var rawAttributeStorage: [String: Any] { get set }
    
    func getAttribute(_ name: String) -> Any?
    func setAttribute(_ name: String, value: Any)
}

public extension RawAttributeable {
    
    func getAttributeUnsafe(_ name: String) -> Any {
        rawAttributeStorage[name]!
    }
    
    func getAttribute(_ name: String) -> Any? {
        rawAttributeStorage[name]
    }
    
    func setAttribute(_ name: String, value: Any) {
        rawAttributeStorage[name] = value
    }
}
