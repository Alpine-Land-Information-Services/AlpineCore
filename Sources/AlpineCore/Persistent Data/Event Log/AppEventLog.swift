//
//  AppEventLog.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/15/24.
//

import Foundation
import SwiftData

@Model
public class AppEventLog {
    
    var timestamp = Date()
    var type: AppEventType
    var event: String
    
    var hidden: Bool?
    var secret: Bool?
    
    var user: CoreUser?
    
    init(_ event: String, hidden: Bool, secret: Bool, type: AppEventType) {
        self.event = event
        self.hidden = hidden
        self.secret = secret
        self.type = type
    }
    
    func toErrorText() -> String {
        "\nAt \(timestamp.toString(format: "HH:mm:ss, MM.d")) ---- \(type.rawValue)\n\(event)"
    }
}
