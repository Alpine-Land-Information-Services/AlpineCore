//
//  AtlasTips.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 2/16/24.
//

import Foundation
import TipKit

public struct CompassMove: Tip {
    
    public init () {}
    
    public var title: Text {
        Text("Drag Me Anywhere!")
    }
    
    public var message: Text? {
        Text("Compass can be moved to any location and will always display on top unless dismissed.")
    }
    
    public var image: Image? {
        Image(systemName: "hand.draw")
    }
}
