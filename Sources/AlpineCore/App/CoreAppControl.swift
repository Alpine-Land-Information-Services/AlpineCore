//
//  CoreAppControl.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 1/18/24.
//

import Foundation
import Observation

import PopupKit

public typealias Core = CoreAppControl
public typealias CoreAlert = SceneAlert

@Observable
public class CoreAppControl {
    
    public static var shared = CoreAppControl()
    
    private init() {}
}

public extension CoreAppControl {
    
    static func makeAlert(_ alert: CoreAlert) {
        DispatchQueue.main.async {
            AlertManager.shared.presentAlert(alert)
        }
    }
}
