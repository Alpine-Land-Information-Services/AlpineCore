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
    
    func resize(to size: CGSize) -> CGImage? {
        guard let colorSpace = self.colorSpace else { return nil }
        
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
                                      bitmapInfo: self.bitmapInfo.rawValue) else {
            print("⛔️ Error: Unable to create CGContext.")
            return nil
        }
        
        context.interpolationQuality = .low
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
