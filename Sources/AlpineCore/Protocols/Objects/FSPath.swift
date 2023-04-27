//
//  FSPath.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/18/23.
//

import Foundation

public struct FSPath: LosslessStringConvertible {
    
    public var description: String

    public init(_ description: String) {
        self.description = description
    }
}

extension FSPath: Codable {
    
    enum CodingKeys: String, CodingKey {
        case path
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(description, forKey: .path)
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        description = try values.decode(String.self, forKey: .path)
    }
}

public extension FSPath {
    
    var string: String {
        String(self)
    }
    
    var removeLast: FSPath {
        let components = self.string.components(separatedBy: "/")
        return components.dropLast().joined(separator: "/").fsPath
    }

    var fileName: String {
        self.string.components(separatedBy: "/").last!
    }
    
    var fullPath: FSPath {
        return FS.documentsDirectory.absoluteString.appending("/\(self.string)").fsPath
    }
    
    func appending(item: String) -> FSPath {
        FSPath(self.string.appending("/\(item)"))
    }
    
    func equals(_ other: FSPath) -> Bool {
        self.string == other.string
    }
}

