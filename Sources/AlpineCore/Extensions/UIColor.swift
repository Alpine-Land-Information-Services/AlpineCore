//
//  UIColor.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 7/26/23.
//

import UIKit

public extension UIColor {
    
    convenience init(hex: String) {
        var hexSanitized: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        if (hexSanitized.count != 6 && hexSanitized.count != 8) {
            self.init(red: 0, green: 0, blue: 0, alpha: 1)
            return
        }
        var rgbValue: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgbValue)
        let a: CGFloat = hexSanitized.count == 6 ? 1.0 : CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
        let r: CGFloat = CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0
        let g: CGFloat = CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0
        let b: CGFloat = CGFloat( rgbValue & 0x000000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
