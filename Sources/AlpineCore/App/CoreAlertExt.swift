//
//  CoreAlertExt.swift
//  AlpineCore
//
//  Created by mkv on 1/22/24.
//

import PopupKit

public extension AlertButton {
    
    static var no: AlertButton {
        AlertButton(title: "No", style: .cancel, action: {})
    }
}
