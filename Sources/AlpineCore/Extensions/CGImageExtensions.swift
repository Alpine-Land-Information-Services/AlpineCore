//
//  CGImage.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 10/3/23.
//

import Foundation
import CoreGraphics
import UniformTypeIdentifiers
import ImageIO

public extension CGImage {
    
    static func fromPNG(_ data: Data) -> CGImage? {
        guard let dataProvider = CGDataProvider(data: data as CFData) else {
            return nil
        }
        
        if let cgImage = CGImage(pngDataProviderSource: dataProvider,
                                 decode: nil,
                                 shouldInterpolate: true,
                                 intent: .defaultIntent) {
            return cgImage
        }
        
        return nil
    }
    
    /// Draw 2nd image on the first one. They have to have the same size.
    static func combineImages(_ image1: CGImage?, _ image2: CGImage?) -> CGImage? {
        guard let image1, let colorSpace = image1.colorSpace else { return image2 }
        guard let image2 else { return image1 }
        
        guard let context = CGContext(data: nil,
                                      width: image1.width,
                                      height: image1.height,
                                      bitsPerComponent: image1.bitsPerComponent,
                                      bytesPerRow: 0,
                                      space: colorSpace,
                                      bitmapInfo: image1.bitmapInfo.rawValue) else {
            print("⛔️ Error: Unable to create CGContext.")
            return nil
        }
        context.draw(image1, in: CGRect(x: 0, y: 0, width: image1.width, height: image1.height))
        context.draw(image2, in: CGRect(x: 0, y: 0, width: image1.width, height: image1.height))
        return context.makeImage()
    }
    
    func resize(to size: CGSize) -> CGImage? {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else { return nil }
        
        let destWidth = Int(size.width)
        let destHeight = Int(size.height)
        let bitsPerComponent = self.bitsPerComponent
//        let bytesPerPixel = self.bitsPerPixel / bitsPerComponent
//        let destBytesPerRow = destWidth * bytesPerPixel
        
        guard let context = CGContext(data: nil,
                                      width: destWidth,
                                      height: destHeight,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: 0, // Automatically calculated based on image width
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue) else {
            print("⛔️ Error: Unable to create CGContext.")
            return nil
        }
        
        context.interpolationQuality = .high
        context.draw(self, in: CGRect(origin: .zero, size: size))
        return context.makeImage()
    }
    
    func toData(as type: CFString = UTType.png.identifier as CFString) -> Data? {
        guard let mutableData = CFDataCreateMutable(nil, 0),
              let destination = CGImageDestinationCreateWithData(mutableData, type, 1, nil) else {
            return nil
        }
        
        CGImageDestinationAddImage(destination, self, nil)
        
        guard CGImageDestinationFinalize(destination) else {
            return nil
        }
        
        return mutableData as Data
    }
    
}
