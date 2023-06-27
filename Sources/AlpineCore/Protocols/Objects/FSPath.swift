//
//  FSPath.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/18/23.
//

import Foundation

public struct FSPath: RawRepresentable {
    
    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension FSPath: Codable {
    
    enum CodingKeys: String, CodingKey {
        case path
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }
}

public extension FSPath {
    
    var fileName: String {
        self.rawValue.components(separatedBy: "/").last!
    }
}

public extension FSPath {

    var removeLast: FSPath {
        let components = self.rawValue.components(separatedBy: "/")
        return components.dropLast().joined(separator: "/").fsPath
    }

    var fullPath: FSPath {
        return FS.documentsDirectory.absoluteString.appending("/\(self.rawValue)").fsPath
    }
    
    var url: URL {
        FS.documentsDirectory.appendingPathComponent(self.rawValue)
    }
}

public extension FSPath {
    
    func appending(item: String) -> FSPath {
        FSPath(rawValue: self.rawValue.appending("/\(item)"))
    }
    
    func equals(_ other: FSPath) -> Bool {
        self.rawValue == other.rawValue
    }
}

