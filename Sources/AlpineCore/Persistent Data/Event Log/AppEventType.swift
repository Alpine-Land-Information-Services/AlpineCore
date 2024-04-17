//
//  AppEventType.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/15/24.
//

import Foundation

public enum AppEventType: String, Codable {
    case logging = "Logging"
    case buttonTap = "Button Tap"
    case system = "System"
    case atlas = "Atlas"
}
