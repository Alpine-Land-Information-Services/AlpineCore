//
//  CGPoint.swift
//  AlpineCore
//
//  Created by mkv on 7/30/24.
//

import Foundation

public extension CGPoint {
    
    func squareRect(size: CGFloat) -> CGRect {
        let originX = self.x - size / 2.0
        let originY = self.y - size / 2.0
        return CGRect(x: originX, y: originY, width: size, height: size)
    }
}
