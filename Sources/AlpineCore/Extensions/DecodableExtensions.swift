//
//  Decodable.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 2/21/23.
//

import Foundation

public extension Decodable {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "+inf", negativeInfinity: "+inf", nan: "naN")
        
        return decoder
    }
    
    static func getFromDefaults(key: String) -> Data? {
        UserDefaults.standard.object(forKey: key) as? Data
    }
    
    static func load<Object: Decodable>(from path: FSPath) throws -> Object? {
        guard FS.exists(at: path) else { return nil }
        
        let jsonString = try String.init(contentsOfFile: path.fullPath.rawValue)
        guard let data = jsonString.data(using: .utf8) else { return nil }
        return try decoder.decode(Object.self, from: data)
    }
}

extension Decodable where Self: CoreParameterValueType {
    public static func value(from parameter: CoreAppParameter) -> Self? {
        guard let data = parameter.strValue?.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(Self.self, from: data)
    }
}
