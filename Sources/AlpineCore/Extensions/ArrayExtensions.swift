//
//  Array.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 5/24/23.
//

import Foundation

public extension Array {
    
    /// Moves the element from one index to another.
    /// - Parameters:
    ///   - oldIndex: The index of the element to move.
    ///   - newIndex: The index to move the element to.
    mutating func move(from oldIndex: Index, to newIndex: Index) {
        // Don't work for free and use swap when indices are next to each other -
        // this won't rebuild array and will be super efficient.
        if oldIndex == newIndex { return }
        if abs(newIndex - oldIndex) == 1 { return self.swapAt(oldIndex, newIndex) }
        self.insert(self.remove(at: oldIndex), at: newIndex)
    }
    
    /// Chunks the array into smaller arrays of the given size.
    /// - Parameter size: The size of each chunk.
    /// - Returns: An array of arrays, where each inner array is of the specified size.
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

public extension Array where Element: Equatable {
    
    /// Appends the given element to the array if it does not already exist.
    /// - Parameter newElement: The element to append.
    mutating func appendIfNotExists(_ newElement: Element) {
        if !self.contains(newElement) {
            self.append(newElement)
        }
    }

    /// Removes the given element from the array if it exists.
    /// - Parameter element: The element to remove.
    mutating func removeIfExists(_ element: Element) {
        if let index = self.firstIndex(of: element) {
            self.remove(at: index)
        }
    }

    /// Appends the given optional element to the array if it is not `nil`.
    /// - Parameter newElement: The optional element to append.
    @inlinable
    mutating func append(_ newElement: Element?) {
        if let newElement {
            append(newElement)
        }
    }
}

public extension Array where Element == String {
    
    /// Filters the array to include only elements with the `.json` extension.
    /// - Returns: An array containing only the elements with the `.json` extension.
    func filterJSON() -> [Element] {
        self.filter { Self.getExtension(from: $0) == "json" }
    }
    
    /// Filters the array to exclude elements with the `.json` extension.
    /// - Returns: An array excluding elements with the `.json` extension.
    func noJSON() -> [Element] {
        self.filter { Self.getExtension(from: $0) != "json" }
    }
    
    /// Gets the file extension from the given file name.
    /// - Parameter fileName: The file name to extract the extension from.
    /// - Returns: The file extension in lowercased format.
    static func getExtension(from fileName: String) -> String {
        URL(fileURLWithPath: fileName).pathExtension.lowercased()
    }
}

public extension Array where Element == CGPoint {
    
    /// Determines if the points in the array form a clockwise path.
    /// - Returns: `true` if the points form a clockwise path, otherwise `false`.
    func isClockwise() -> Bool {
        let sum = self.enumerated().reduce(0) { total, current in
            let nextIndex = (current.offset + 1) % self.count
            let nextPoint = self[nextIndex]
            let currentPoint = current.element
            return total + ((nextPoint.x - currentPoint.x) * (nextPoint.y + currentPoint.y))
        }
        return sum > 0
    }
    
    /// Sorts the points in the array either in a clockwise or counterclockwise direction.
    /// - Parameter clockwise: A boolean value indicating whether to sort the points in a clockwise direction.
    /// - Returns: An array of sorted points.
    func sort(clockwise: Bool) -> [CGPoint] {
        // Calculate a 'centroid' that is guaranteed to be inside the bounds of the polygon
        let minX = self.min(by: { $0.x < $1.x })?.x ?? 0
        let maxX = self.max(by: { $0.x < $1.x })?.x ?? 0
        let minY = self.min(by: { $0.y < $1.y })?.y ?? 0
        let maxY = self.max(by: { $0.y < $1.y })?.y ?? 0
        let centroid = CGPoint(x: (minX + maxX) / 2, y: (minY + maxY) / 2)

        // Sort the points based on the angle they form with the centroid
        let sortedPoints = self.sorted {
            let angle1 = atan2($0.y - centroid.y, $0.x - centroid.x)
            let angle2 = atan2($1.y - centroid.y, $1.x - centroid.x)
            return clockwise ? angle1 > angle2 : angle1 < angle2
        }
        return sortedPoints
    }
}

public extension Array where Element: Copying {
    
    /// Creates a deep copy of the array.
    /// - Returns: A new array with copied elements.
    func clone() -> Array {
        var copiedArray = Array<Element>()
        for element in self {
            copiedArray.append(element.copy())
        }
        return copiedArray
    }
}
