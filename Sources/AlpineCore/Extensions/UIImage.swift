//
//  UIImage.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 6/19/23.
//

import UIKit

public extension UIImage {
    
    func toBitmap() -> UIImage? {
        let size = self.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let bitmapImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return bitmapImage
    }
    
    func alpha(_ value: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        defer { UIGraphicsEndImageContext() }

        let context = UIGraphicsGetCurrentContext()!
        let cgImage = self.cgImage!

        let area = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)

        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: -area.size.height)

        context.setBlendMode(.multiply)
        context.setAlpha(value)

        context.draw(cgImage, in: area)

        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}
