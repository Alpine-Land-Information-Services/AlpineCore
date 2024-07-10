//
//  TapGestureRecognizer.swift
//  
//
//  Created by Vladislav on 7/10/24.
//

import Foundation
import UIKit

class TapGestureRecognizer: UITapGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if let touch = touches.first, touch.tapCount == 1 {
            super.touchesBegan(touches, with: event)
        } else {
            state = .cancelled
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .cancelled
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        if let touch = touches.first, touch.tapCount == 1 {
            super.touchesEnded(touches, with: event)
        } else {
            state = .cancelled
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .cancelled
    }
}
