//
//  File.swift
//  
//
//  Created by Vladislav on 7/11/24.
//

import Foundation

public extension KeyedEncodingContainer {
    
    mutating func encodeIfNotDefault<T: Encodable & Equatable>(_ value: T?, forKey key: KeyedEncodingContainer<K>.Key, defaultValue: T) throws {
        if let value = value, value != defaultValue {
            try encode(value, forKey: key)
        }
    }
}

