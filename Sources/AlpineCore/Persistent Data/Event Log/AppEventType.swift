//
//  AppEventType.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/15/24.
//

import Foundation

public enum AppEventType: String, Codable {
    case log = "Log"
    case userAction = "User Action"
    case system = "System"
    case atlas = "Atlas"
}
