//
//  CoreError.swift
//  AlpineCore
//
//  Created by mkv on 4/17/24.
//

import Foundation

public class CoreError: AlpineError {
    
    var type: CoreErrorType
    
    public init(_ message: String,
                type: CoreErrorType,
                includedFile: [ExportType] = [],
                file: String = #file, function: String = #function, line: Int = #line) {
        self.type = type
        super.init(message, file: file, function: function, line: line, includedFile: includedFile)
    }
    
    public override func getType() -> String {
        "\(type.rawValue)"
    }
}
