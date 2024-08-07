//
//  AppError.swift
//  AlpineCore
//
//  Created by mkv on 1/19/24.
//

import Foundation
import SwiftData

@Model
public class AppError: Hashable {
    
    public enum IssueLevel: String, CaseIterable {
        case nonUrgent = "Not Urgent"
        case medium = "Unable to Complete Task"
        case broken = "Application not Usable"
    }
    
    var guid = UUID()
    var date = Date()
    var file: String?
    var function: String?
    var line: Int?
    var message: String?
    var additionalInfo: String?
    var typeName: String?
    var dateSent: Date?
    var report: String?
    var user: CoreUser?
    var events: [AppEventLog]?
    
    public var title: String {
        typeName ?? "System error"
    }
    
    public var content: String {
        message ?? "No error description"
    }
    
    private init(error: Error, additionalText: String? = nil) {
        if let err = error as? AlpineError {
            self.typeName = err.getType()
            self.file = err.file
            self.function = err.function
            self.line = err.line
            self.message = err.message
        } else {
            self.message = "\(error)"
        }
        
        self.additionalInfo = additionalText
    }
    
    public static func create(error: Error, additionalInfo: String? = nil, in context: ModelContext) -> AppError {
        let error = AppError(error: error, additionalText: additionalInfo)
        context.insert(error)
        try? context.save()
        
        return error
    }
    
    public func markSent() {
        report = nil
        dateSent = Date()
        
        try? modelContext?.save()
    }
    
    public func send() {
        guard let user else {
            modelContext?.delete(self)
            return
        }
        
        let sender = SupportTicketSender()
        sender.sendBackgroundReport(title: title, message: report ?? "_ERROR_SENT_WITH_NO_REPORT_CREATED_", email: user.id) { sent in
            if sent {
                self.markSent()
            }
        }
    }
    
    public func createReport(issueLevel: IssueLevel, comments: String, repeatable: Bool) -> String {
        var text = """
                    \(title)
                    
                    <--- Bug Severity --->
                    \(issueLevel.rawValue)
                    
                    <--- Is Able To Replicate --->
                    \(repeatable ? "YES" : "NO")
                    
                    <--- Associated Error --->
                    [file] \(file ?? "Unknown")
                    [function] \(function ?? "Unknown")
                    [line] \(line != nil ? String(line!) : "Unknown")
                    
                    \(content)
                    
                    \((additionalInfo != nil && additionalInfo != "") ? "[Additional Info]\n\(additionalInfo!)" : "")
                    
                    """
        if !comments.isEmpty {
            text.append("<--- User Description --->\n\(comments)")
        }
        
        if let events = events?.sorted(by: { $0.timestamp > $1.timestamp }) {
            var errorEvents = "\n\n<--- Events --->"
            for event in events {
                errorEvents.append(event.toErrorText())
            }
            text.append(errorEvents)
        }
        
        report = text
        return text
    }
}
