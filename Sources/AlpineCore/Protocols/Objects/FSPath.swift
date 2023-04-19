//
//  FSPath.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/18/23.
//

import Foundation

public protocol FSPath: LosslessStringConvertible {}

public struct PathString: FSPath {
    
    public var description: String

    public init(_ description: String) {
        self.description = description
    }
}

public extension FSPath {
    
    var string: String {
        String(self)
    }

    var fileName: String {
        self.string.components(separatedBy: "/").last!
    }
    
    var fullPath: FSPath {
        return FS.documentsDirectory.absoluteString.appending("/\(self.string)").fsPath
    }
    
    func appending(item: String) -> FSPath {
        PathString(self.string.appending("/\(item)"))
    }
    
    func equals(_ other: FSPath) -> Bool {
        self.string == other.string
    }
    
//    var justPath: String {
//        var components = self.string.components(separatedBy: "/")
//        components.removeLast()
//        return Array(components).joined(separator: "/")
//    }
}

