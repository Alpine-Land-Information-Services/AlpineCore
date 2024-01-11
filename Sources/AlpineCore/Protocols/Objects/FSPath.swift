//
//  FSPath.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/18/23.
//

import Foundation

public struct FSPath: RawRepresentable {
    
    @available(*, deprecated, message: "User specific raw")
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
    
    var rawFolder: String {
        if rawValue.last == "/" {
            return rawValue
        }
        return rawValue.appending("/")
    }
    
    var rawFile: String {
        if rawValue.last == "/" {
            var modified = rawValue
            modified.removeLast()
            
            return modified
        }
        return rawValue
    }
}

@available(iOS 16.0, *)
public extension FSPath {
    
    func fullPath(in type: FS.PathType) -> FSPath {
        switch type {
        case .documents:
            return FS.appDoucumentsURL.path.appending("/\(rawValue)").fsPath
        case .group:
            return FS.atlasGroupURL.path.appending("/\(rawValue)").fsPath
        }
    }
    
    func url(in type: FS.PathType) -> URL {
        switch type {
        case .documents:
            return FS.appDoucumentsURL.appending(path: rawValue)
        case .group:
            return FS.atlasGroupURL.appending(path: rawValue)
        }
    }
}

public extension FSPath {
    
    var removeExtension: FSPath {
        let components = self.rawValue.components(separatedBy: ".")
        return components.dropLast().joined(separator: ".").fsPath
    }

    var removeLast: FSPath {
        let components = self.rawValue.components(separatedBy: "/")
        return components.dropLast().joined(separator: "/").fsPath
    }

    @available(*, deprecated, message: "use fullPath()")
    var fullPath: FSPath {
        return FS.documentsDirectory.absoluteString.appending("/\(self.rawValue)").fsPath
    }
    
    @available(*, deprecated, message: "use url()")
    var url: URL {
        if #available(iOS 16.0, *) {
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: self.rawValue)
        } else {
            FS.documentsDirectory.appendingPathComponent("/\(self.rawValue)")
        }
    }
}

public extension FSPath {
    
    func appending(_ item: String) -> FSPath {
        FSPath(rawValue: self.rawValue.appending("/").appending(item))
    }
    
    func equals(_ other: FSPath) -> Bool {
        self.rawValue == other.rawValue
    }
}

