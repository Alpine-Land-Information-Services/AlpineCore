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
    
    var user: CoreUser?
    
    init(_ event: String, type: AppEventType) {
        self.event = event
        self.type = type
    }
}
