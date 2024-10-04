//
//  AtlasFeatureSyncData.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 1/25/24.
//

import Foundation

public struct AtlasFieldData {
    
    public init(name: String, value: Any) {
        self.name = name
        self.value = value
    }
    
    public var name: String
    public var value: Any
    
    public static func convertToDictionary(_ array: [AtlasFieldData]) -> [String: Any] {
        var result = [String: Any]()
        for item in array {
            result[item.name] = item.value
        }
        return result
    }
}

public struct AtlasFeatureData {
    
    public init(wkt: String, fields: [AtlasFieldData]) {
        self.wkt = wkt
        self.fields = fields
    }
    
    public var wkt: String
    public var fields: [AtlasFieldData]
}
