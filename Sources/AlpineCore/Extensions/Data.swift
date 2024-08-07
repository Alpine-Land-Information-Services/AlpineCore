//
//  Data.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 2/21/23.
//

import Foundation

public extension Data {
    
    var bytes: [UInt8] {
        return [UInt8](self)
    }
    
    var prettyJson: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]),
              let prettyPrintedString = String(data: data, encoding:.utf8)
        else { return nil }

        return prettyPrintedString
    }
    
    func prettyJSON() throws -> String {
        let object = try JSONSerialization.jsonObject(with: self, options: [])
        let data = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys])
        guard let prettyPrintedString = String(data: data, encoding:.utf8) else {
            throw CoreError("Could not make a pretty JSON String.", type: .json)
        }
        
        return prettyPrintedString
    }
    
    func decode(as type: Decodable.Type) -> Decodable? {
        try? JSONDecoder().decode(type, from: self)
    }
}
