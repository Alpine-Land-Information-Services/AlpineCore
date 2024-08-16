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
    
    public var userID: String?
    
    var timestamp = Date()
    var type: AppEventType
    var event: String
    var parameters: [String: String]?
    
    init(_ event: String, type: AppEventType, userID: String, rawParameters: [String: Any]? = nil) {
        self.event = event
        self.type = type
        self.userID = userID
        
        self.parameters = rawParameters?.compactMapValues { value in
            return "\(value)"
        }
    }
    
    func toErrorText() -> String {
        var logMessage = """
        \n```
        \(event.uppercased()) @ \(timestamp.toString(format: "MMM d HH:mm:ss"))
        """
        
        if let parameters = parameters, !parameters.isEmpty {
            logMessage += "\nParameters:"
            for (key, value) in parameters {
                logMessage += "\n - \(key): \(value)"
            }
        }
        
        logMessage += "\n```"
        
        return logMessage
    }
}
