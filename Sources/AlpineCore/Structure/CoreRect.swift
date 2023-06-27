//
//  CoreRect.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 6/27/23.
//

import Foundation

public struct CoreRect: Codable {
    
    public init(_ width: Double, _ height: Double) {
        self.width = width
        self.height = height
    }
    
    public var width: Double
    public var height: Double
}
