//
//  Color.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 5/3/23.
//

import SwiftUI

public extension Color {
    
    init(_ hexString: String) {
        let scanner = Scanner(string: hexString)
        var hexValue: UInt64 = 0
        
        if scanner.scanHexInt64(&hexValue) {
            let r = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
            let g = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
            let b = CGFloat((hexValue & 0x0000FF00) >> 8) / 255.0
            let a = CGFloat(hexValue & 0x000000FF) / 255.0
            
            self.init(red: r, green: g, blue: b, opacity: a)
        }
        else {
            self.init(.black) // Fallback color in case of an error
        }
    }
    
    var toInt: String {
        // Convert Color to CGColor
        guard let cgColor = self.cgColor else { return "000"}
        
        // Get color components
        let components = cgColor.components ?? []
        guard components.count >= 4 else { return "000"}
        
        let r = UInt32(components[0] * 255.0)
        let g = UInt32(components[1] * 255.0)
        let b = UInt32(components[2] * 255.0)
        let a = UInt32(components[3] * 255.0)
        
        // Combine the components into an UInt32
        let colorInt = (r << 24) | (g << 16) | (b << 8) | a
        return String(colorInt)
    }
}
