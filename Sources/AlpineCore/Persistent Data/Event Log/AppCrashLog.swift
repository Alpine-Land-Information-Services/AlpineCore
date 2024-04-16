//
//  AppCrashLog.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/16/24.
//

import Foundation
import SwiftData

@Model
public class AppCrashLog {
    
    var appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    
    var timestamp = Date()
    var events: [AppEventLog]?
    
    var user: CoreUser?

    
    var reportDate: Date?
    var isReported: Bool {
        reportDate != nil
    }
    
    public init() {}
}

public extension AppCrashLog {
    
    func send() {
        guard let user else { return }
        
        let sender = SupportTicketSender()
        var text = """
        Crash at \(timestamp.toString(format: "HH:mm:ss, MM.d"))
        App Version: \(appVersion)
        
        """
    
        if let events = events?.sorted(by: { $0.timestamp > $1.timestamp }) {
            var errorEvents = "\n\n<--- Events --->"
            for event in events {
                errorEvents.append(event.toErrorText())
            }
            text.append(errorEvents)
        }
        
        sender.sendBackgroundReport(title: "Application Crash", message: text, email: user.id) { success in
            if success {
                self.reportDate = Date()
            }
        }
    }
}

