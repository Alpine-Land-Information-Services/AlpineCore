//
//  AtlasObject.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 1/25/24.
//

import Foundation
import CoreData

public protocol AtlasObject {
    
    static var geometryType: UInt32 { get }
    
    static var connectionPath: String { get }
    static var fileExtension: String { get }
    static var layerName: String { get }
    
    var geometry: String? { get set }
}

public extension AtlasObject {
    
    static var connectionString: String {
        connectionPath + fileName
    }
    
    static var fileName: String {
        layerName + "." + fileExtension
    }
}

public extension AtlasObject {
    
    var geometryType: UInt32 {
        Self.geometryType
    }
    
    var layerName: String {
        Self.layerName
    }
}

