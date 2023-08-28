//
//  NSNumber.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 8/28/23.
//

import Foundation

public extension Optional where Wrapped == NSNumber {
    
    func toText() -> String {
        self != nil ? self == 1 ? "True" : "False" : "Not Set"
    }
}

public extension NSNumber {
    
    
}
