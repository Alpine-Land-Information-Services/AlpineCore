//
//  Token.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 3/6/24.
//

import Foundation

public struct Token: Codable {
    
    public init(rawValue: String, expirationDate: Date) {
        self.rawValue = rawValue
        self.expirationDate = expirationDate
    }
    
    public var rawValue: String
    public var expirationDate: Date
    
    public var encoded: Data? {
        try? JSONEncoder().encode(self)
    }
}
