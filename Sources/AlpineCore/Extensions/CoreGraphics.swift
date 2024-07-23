//
//  CoreGraphics.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 7/23/24.
//

import Foundation

public extension CGSize {
    
    static func +(lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    
    static func +=(lhs: inout CGSize, rhs: CGSize) {
        lhs = lhs + rhs
    }
    
    static func -(lhs: Self, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width - rhs, height: lhs.height - rhs)
    }
    
    static func *(lhs: Self, mult: CGFloat) -> CGSize {
        CGSize(width: lhs.width * mult, height: lhs.height * mult)
    }
    
    static func /(lhs: Self, div: CGFloat) -> CGSize {
        CGSize(width: lhs.width / div, height: lhs.height / div)
    }
    
    func center() -> CGPoint {
        CGPoint(x: self.width / 2, y: self.height / 2)
    }
    
    func proportion() -> Double {
        width != 0 ? height / width : 0
    }
    
    func isCorrect() -> Bool {
        self.width > 0 && self.height > 0 && self.width.isFinite && self.height.isFinite
    }
}


public extension CGPoint {
    
    static func *(lhs: Self, mult: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * mult, y: lhs.y * mult)
    }
    
    static func /(lhs: Self, div: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x / div, y: lhs.y / div)
    }
    
    static func +(lhs: Self, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x + rhs, y: lhs.y + rhs)
    }
    
    static func -(lhs: Self, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x - rhs, y: lhs.y - rhs)
    }
    
    func distance(to: CGPoint) -> CGFloat {
        return sqrt(pow((to.x - self.x), 2) + pow((to.y - self.y), 2))
    }
}
