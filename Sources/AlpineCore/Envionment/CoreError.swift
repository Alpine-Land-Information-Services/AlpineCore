//
//  CoreError.swift
//  AlpineCore
//
//  Created by mkv on 4/17/24.
//

import Foundation

public class CoreError: AlpineError {
    
    var type: CoreErrorType
    
    public init(_ message: String, type: CoreErrorType, file: String = #file, function: String = #function, line: Int = #line) {
        self.type = type
        super.init(message, file: file, function: function, line: line)
    }
    
    public override func getType() -> String {
        "\(type.rawValue)"
    }
}

public enum CoreErrorType: String {
    case fileSystem = "File System Error"
    case json = "JSON Error"
    case `nil` = "Unwrapping Error"
}
