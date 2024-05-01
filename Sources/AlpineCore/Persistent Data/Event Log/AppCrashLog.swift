//
//  AppCrashLog.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/16/24.
//

import Foundation
import SwiftData
import UIKit

@Model
public class AppCrashLog {
    
    var appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    
    var timestamp = Date()
    var events: [AppEventLog]?
    
    var user: CoreUser?
    var userID: String?
    
    var lastDateLaunch: Date?

    var reportDate: Date?
    var isReported: Bool {
        reportDate != nil
    }
    
    public init() {}
}

public extension AppCrashLog {
    
    func send(userID: String) {
        
        let sender = SupportTicketSender()
        var text = """
        Log recorded at \(timestamp.toString(format: "HH:mm:ss, MM.d"))
        
        """
        if let lastDateLaunch {
            let (hours, minute) = lastDateLaunch.hoursAndMinutes(to: timestamp)
            let lastLuanch = "App active time: \(hours) hours, and \(minute) minutes \nfrom \(timestamp.toString(format: "HH:mm:ss, MM.d"))"
            text.append(lastLuanch)
        }
        
        
        if let events = events?.sorted(by: { $0.timestamp > $1.timestamp }) {
            var errorEvents = "\n\n<--- Events --->"
            for event in events {
                errorEvents.append(event.toErrorText())
            }
            text.append(errorEvents)
        }
        
        sender.sendBackgroundReport(title: "Application Crash", message: text, email: userID) { [self] success in
            if success {
                reportDate = Date()
            }
        }
    }
}

