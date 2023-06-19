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
}
