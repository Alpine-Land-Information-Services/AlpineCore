//
//  Codable.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 2/21/23.
//

import Foundation

public extension Decodable {
    
    static func getFromDefaults(key: String) -> Data? {
        UserDefaults.standard.object(forKey: key) as? Data
    }
    
    static func load<Object: Decodable>(from path: FSPath) throws -> Object? {
        guard FS.exists(at: path.fullPath) else { return nil }
        
        let jsonString = try String.init(contentsOfFile: path.fullPath.rawValue)
        guard let data = jsonString.data(using: .utf8) else { return nil }
        return try JSONDecoder().decode(Object.self, from: data)
    }
}

public extension Encodable {
    
    func save(to path: FSPath) throws {
        let data = try JSONEncoder().encode(self)
        if let json = data.prettyJson {
            try json.write(toFile: path.fullPath.rawValue, atomically: true, encoding: .utf8)
        }
    }
    
    func saveToDefaults(key: String) {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}

public extension KeyedEncodingContainer {
    
    mutating func encodeIfNotDefault<T: Encodable & Equatable>(_ value: T?, forKey key: KeyedEncodingContainer<K>.Key, defaultValue: T) throws {
        if let value = value, value != defaultValue {
            try encode(value, forKey: key)
        }
    }
}


