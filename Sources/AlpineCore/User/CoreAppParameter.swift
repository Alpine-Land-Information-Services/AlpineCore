//
//  CoreAppParameter.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 6/7/24.
//

import Foundation
import SwiftData

@Model
final public class CoreAppParameter {
    
    public var key: String = "_INVALID_PARAMETER_KEY_"
    
    public var strValue: String?
    public var intValue: Int?
    
    public var dataValue: Data?
    
    private init() {}
    
    public convenience init(key: String, strValue: String? = nil, intValue: Int? = nil, dataValue: Data? = nil) {
        self.init()
        
        self.strValue = strValue
        self.intValue = intValue
        self.dataValue = dataValue
    }
}

public protocol CoreParameterValueType: Codable {
    static func value(from parameter: CoreAppParameter) -> Self?
}

public extension CoreParameterValueType where Self: Codable {
    
    static func value(from parameter: CoreAppParameter) -> Self? {
        guard let dataValue = parameter.dataValue else { return nil }
        return try? JSONDecoder().decode(Self.self, from: dataValue)
    }
}

extension String: CoreParameterValueType {
    public static func value(from parameter: CoreAppParameter) -> String? {
        return parameter.strValue
    }
}

extension Int: CoreParameterValueType {
    public static func value(from parameter: CoreAppParameter) -> Int? {
        return parameter.intValue
    }
}

extension Decodable where Self: CoreParameterValueType {
    public static func value(from parameter: CoreAppParameter) -> Self? {
        guard let data = parameter.strValue?.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(Self.self, from: data)
    }
}

extension Encodable where Self: CoreParameterValueType & Decodable {
    public static func value(from parameter: CoreAppParameter) -> Self? {
        guard let data = parameter.strValue?.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(Self.self, from: data)
    }
}
