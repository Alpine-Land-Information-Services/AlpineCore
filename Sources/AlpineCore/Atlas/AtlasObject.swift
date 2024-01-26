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
    
    var geometry: String? { get set }
}


