//
//  Array.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 5/24/23.
//

import Foundation


public extension Array where Element: Equatable {
    
    mutating func appendIfNotExists(_ newElement: Element) {
        if !self.contains(newElement) {
            self.append(newElement)
        }
    }
    
    mutating func removeIfExists(_ element: Element) {
        if let index = self.firstIndex(of: element) {
            self.remove(at: index)
        }
    }
}
