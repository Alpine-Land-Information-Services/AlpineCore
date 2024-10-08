//
//  AlpineError.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 10/11/23.
//

import Foundation

open class AlpineError: Error {
    
    public var message: String
    public var file: String
    public var function: String
    public var line: Int
    public var includedFile: [ExportType]
    
    public init(_ message: String, file: String, function: String, line: Int, includedFile: [ExportType] = []) {
        self.message = message
        self.file = file
        self.function = function
        self.line = line
        self.includedFile = includedFile
    }
    
    open func getType() -> String {
        "\(String(describing: Self.self))"
    }
}
