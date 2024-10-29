//
//  Encodable.swift
//  
//
//  Created by Vladislav on 7/11/24.
//

import Foundation

public extension Encodable {
    
    var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: "+inf", negativeInfinity: "+inf", nan: "naN")
        
        return encoder
    }
    
    func save(to path: FSPath) throws {
        let data = try encoder.encode(self)
        if let json = data.prettyJson {
            try json.write(toFile: path.fullPath(in: .documents).rawValue, atomically: true, encoding: .utf8)
        }
    }
    
    func saveToDefaults(key: String) {
        if let encoded = try? encoder.encode(self) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}

extension Encodable where Self: CoreParameterValueType & Decodable {
    public static func value(from parameter: CoreAppParameter) -> Self? {
        guard let data = parameter.strValue?.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(Self.self, from: data)
    }
}
