//
//  CoreAppActor.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/15/24.
//

import Foundation
import SwiftData

actor CoreAppActor: ModelActor {
    
    let modelContainer: ModelContainer
    let modelExecutor: ModelExecutor
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        let context = ModelContext(modelContainer)
        modelExecutor = DefaultSerialModelExecutor(modelContext: context)
    
    }
    
    func save() throws {
        try modelContext.save()
    }
}

extension CoreAppActor { //MARK: Events
    
    func createEvent(_ event: String, type: AppEventType, hidden: Bool, userID: PersistentIdentifier?) {
        let event = AppEventLog(event, hidden: hidden, type: type)
        modelContext.insert(event)
        
        if let userID {
            let user = modelContext.model(for: userID) as? CoreUser
            event.user = user
        }

        try? save()
    }
    
    func clearOldEvents() throws {
        for event in try getOldEvents() {
            modelContext.delete(event)
        }
        
        try modelContext.save()
    }
    
    func getRecentEvents() throws -> [AppEventLog] {
        let fifteenMinAgo = Date().addingTimeInterval(-900)
        
        let descriptor = FetchDescriptor(predicate: #Predicate<AppEventLog> { $0.timestamp >= fifteenMinAgo })
        return try modelContext.fetch(descriptor)
    }
    
    func getOldEvents() throws -> [AppEventLog] {
        let fiveDaysAgo = Date().addingTimeInterval(-432000)
        
        let descriptor = FetchDescriptor(predicate: #Predicate<AppEventLog> { $0.timestamp >= fiveDaysAgo })
        return try modelContext.fetch(descriptor)
    }
}

extension CoreAppActor { //MARK: Errors
    
    public func createError(error: Error, additionalInfo: String? = nil, userId: PersistentIdentifier) -> PersistentIdentifier {
        let error = AppError.create(error: error, additionalInfo: additionalInfo, in: modelContext)
        error.events = try? getRecentEvents()
        let user = modelContext.model(for: userId) as? CoreUser
        user?.errors.append(error)
        
        try? save()
        
        return error.persistentModelID
    }
    
    func attemptSendPendingErrors() throws {
        for error in try getPendingErrors() {
            error.send()
            Core.makeEvent("error log uploaded", type: .log)
        }
    }
    
    private func getPendingErrors() throws -> [AppError] {
        let descriptor = FetchDescriptor(predicate: #Predicate<AppError> { $0.report != nil })
        return try modelContext.fetch(descriptor)
    }
}

extension CoreAppActor { //MARK: Crashes
    
    public func createCrashLog(userID: PersistentIdentifier) {
        let log = AppCrashLog()
        modelContext.insert(log)
        
        log.user = modelContext.model(for: userID) as? CoreUser
        log.events = try? getRecentEvents()
        
        log.send()

        try? save()        
    }
    
    func attemptSendPendingCrashes() throws {
        for crash in try getNotReportedCrashes() {
            crash.send()
            Core.makeEvent("crash log uploaded", type: .log)
        }
        
        try save()
    }
    
    private func getNotReportedCrashes() throws -> [AppCrashLog] {
        let descriptor = FetchDescriptor(predicate: #Predicate<AppCrashLog> { $0.reportDate == nil })
        return try modelContext.fetch(descriptor)
    }
}
