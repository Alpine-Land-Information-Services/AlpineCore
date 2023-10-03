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
}

public extension CGImage {
    
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
