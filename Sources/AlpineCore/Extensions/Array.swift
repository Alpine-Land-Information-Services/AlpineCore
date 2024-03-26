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
    
    @inlinable
    mutating func append(_ newElement: Element?) {
        if let newElement {
            append(newElement)
        }
    }
}


public extension Array {
    
    mutating func move(from oldIndex: Index, to newIndex: Index) {
        // Don't work for free and use swap when indices are next to each other - 
        // this won't rebuild array and will be super efficient.
        if oldIndex == newIndex { return }
        if abs(newIndex - oldIndex) == 1 { return self.swapAt(oldIndex, newIndex) }
        self.insert(self.remove(at: oldIndex), at: newIndex)
    }
}
