//
//  AlertButton.swift
//  AlpineCore
//
//  Created by mkv on 1/22/24.
//

import PopupKit
import Foundation

public extension AlertButton {
    
    static var no: AlertButton {
        AlertButton(title: "No", style: .cancel, action: {})
    }
    
    static var doRestart: AlertButton {
        AlertButton(title: "Quit App", action: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                exit(0)
            }
        })
    }
}
