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
    
    func scaled(by scale: CGFloat) -> UIImage? {
        let newSize = CGSize(width: self.size.width * scale, height: self.size.height * scale)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
    func colored(with color: UIColor) -> UIImage {
        let imageSize = self.size
        let imageScale = self.scale
        let contextBounds = CGRect(origin: CGPoint.zero, size: imageSize)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, imageScale)
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        
        // Flip the context coordinate space to match UIImage
        context.translateBy(x: 0, y: imageSize.height)
        context.scaleBy(x: 1.0, y: -1.0)

        // Draw original image
        context.draw(self.cgImage!, in: contextBounds)
        
        // Apply the color
        context.setBlendMode(.sourceAtop)
        context.setFillColor(color.cgColor)
        context.fill(contextBounds)
        
        // Get the colored image
        let coloredImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return coloredImage ?? self
    }
    
    func tinted(with color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        color.setFill()

        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)

        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        guard let mask = self.cgImage else { return self }
        context.clip(to: rect, mask: mask)
        context.fill(rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()

        return newImage
    }
    
    func resized(to size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func resized(withMaximumSideLength maxLength: CGFloat) -> UIImage? {
        let scale: CGFloat
        if size.width > size.height {
            scale = maxLength / size.width
        } else {
            scale = maxLength / size.height
        }
        
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        return resized(to: newSize)
    }
}
