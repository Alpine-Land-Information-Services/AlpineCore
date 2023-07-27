//
//  JSON.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 7/27/23.
//

import Foundation

public extension KeyedDecodingContainer {
    
    func customDecodeArray<T>(_ type: T.Type, forKey key: K, using initializer: (Decoder) throws -> T) throws -> [T] {
        var items = [T]()
        var nested = try nestedUnkeyedContainer(forKey: key)
        while !nested.isAtEnd {
            let decoder = try nested.superDecoder()
            let item = try initializer(decoder)
            items.append(item)
        }
        return items
    }
    
    func customDecodeObject<T>(_ type: T.Type, forKey key: K, using initializer: (Decoder) throws -> T) throws -> T {
        let decoder = try superDecoder(forKey: key)
        return try initializer(decoder)
    }
}
