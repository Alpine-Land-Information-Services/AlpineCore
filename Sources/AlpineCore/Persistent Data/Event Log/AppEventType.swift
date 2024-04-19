//
//  AppEventType.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/15/24.
//

import Foundation

public enum AppEventType: String, Codable, CaseIterable {
    case log = "Log"
    case userAction = "User Action"
    case system = "System"
    case atlas = "Atlas"
    case error = "Error"
    case atlasApp = "Atlas App"
    case sync = "Sync"
    
    var isDefaultHidden: Bool {
        switch self {
        case .log:
            false
        case .userAction:
            false
        case .system:
            false
        case .atlas:
            true
        case .error:
            true
        case .atlasApp:
            false
        case .sync:
            true
        }
    }
}
