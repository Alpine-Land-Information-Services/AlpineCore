//
//  AppEventType.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/15/24.
//

import SwiftUI

public enum AppEventType: String, Codable, CaseIterable {
    case log = "Log"
    case userAction = "User Action"
    case system = "System"
    case atlas = "Atlas"
    case error = "Error"
    case atlasApp = "Atlas App"
    case sync = "Sync"
    case storage = "Storage"
    
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
        case .storage:
            true
        }
    }
    
    var color: Color {
        switch self {
        case .log:
                .gray
        case .userAction:
                .green
        case .system:
                .accentColor
        case .atlas:
                .blue
        case .error:
                .red
        case .atlasApp:
                .purple
        case .sync:
                .orange
        case .storage:
                .mint
        }
    }
}
