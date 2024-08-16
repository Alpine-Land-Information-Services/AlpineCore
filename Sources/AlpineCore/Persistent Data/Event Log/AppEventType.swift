//
//  AppEventType.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/15/24.
//

import SwiftUI

public enum AppEventType: String, Codable, CaseIterable {

    case userAction = "User Action"
    case system = "System"
    case log = "Log"
    case error = "Error"
    case sync = "Sync"
    case storage = "Storage"
    case atlas = "Atlas"
    case atlasApp = "Atlas App"
    
    public var isDefaultHidden: Bool {
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
    
    public var description: String {
        switch self {
        case .log:
                "log"
        case .userAction:
                "user_action"
        case .system:
                "system"
        case .atlas:
                "atlas"
        case .error:
                "error"
        case .atlasApp:
                "atlas_app"
        case .sync:
                "sync"
        case .storage:
                "storage"
        }
    }
}
