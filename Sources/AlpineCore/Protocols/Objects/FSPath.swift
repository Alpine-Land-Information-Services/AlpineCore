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
    
    func fullPath(in type: FS.PathType) -> FSPath {
        switch type {
        case .documents:
            return FS.appDoucumentsURL.path.appending("/\(rawValue)").fsPath
        case .group:
            return FS.atlasGroupURL.path.appending("/\(rawValue)").fsPath
        }
    }
    
    @available(iOS 16.0, *)
    func url(in type: FS.PathType) -> URL {
        switch type {
        case .documents:
            return FS.appDoucumentsURL.appending(path: rawValue)
        case .group:
            return FS.atlasGroupURL.appending(path: rawValue)
        }
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
        FSPath(rawValue: self.rawValue.appending("/\(item)"))
    }
    
    func equals(_ other: FSPath) -> Bool {
        self.rawValue == other.rawValue
    }
}

