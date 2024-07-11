//
//  CoreParameterValueType.swift
//  
//
//  Created by Vladislav on 7/11/24.
//

import Foundation

public protocol CoreParameterValueType: Codable {
    static func value(from parameter: CoreAppParameter) -> Self?
}

public extension CoreParameterValueType where Self: Codable {
    static func value(from parameter: CoreAppParameter) -> Self? {
        guard let dataValue = parameter.dataValue else { return nil }
        return try? JSONDecoder().decode(Self.self, from: dataValue)
    }
}


