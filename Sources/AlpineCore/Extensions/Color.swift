//
//  Color.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 5/3/23.
//

import SwiftUI

public extension Color {
    
//    init(hex: String) {
//           let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//           var int: UInt64 = 0
//           Scanner(string: hex).scanHexInt64(&int)
//           let a, r, g, b: UInt64
//           switch hex.count {
//               case 3: // RGB (12-bit)
//                   (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//               case 6: // RGB (24-bit)
//                   (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//               case 8: // ARGB (32-bit)
//                   (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//               default:
//                   (a, r, g, b) = (255, 0, 0, 0)
//           }
//           self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
//       }
    
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            self.init(CGColor.init(red: 0, green: 0, blue: 0, alpha: 1))
            return
        }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            self.init(CGColor.init(red: 0, green: 0, blue: 0, alpha: 1))
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
    
    func toHex(includeAlpha: Bool = true) -> String {
        let components = self.cgColor?.components ?? [0, 0, 0, 0]
        let r = components[0]
        let g = components[1]
        let b = components[2]
        let a = components.count >= 4 ? components[3] : 1.0

        if includeAlpha {
            return String(format: "#%02lX%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)), lroundf(Float(a * 255)))
        } else {
            return String(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        }
    }
}
