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
    
    
    var user: CoreUser?
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        let context = ModelContext(modelContainer)
        modelExecutor = DefaultSerialModelExecutor(modelContext: context)
    
    }
    
    func assignUser(userID: PersistentIdentifier) {
        user = modelContext.model(for: userID) as? CoreUser
    }
    
    func save() {
        try? modelContext.save()
    }
}

extension CoreAppActor { //MARK: Events
    
    func createEvent(_ event: String, type: AppEventType, hidden: Bool, secret: Bool, userID: String) {
        let event = AppEventLog(event, hidden: hidden, secret: secret, type: type, userID: userID)
        modelContext.insert(event)
        
        try? modelContext.save()
    }
    
    func clearOldEvents() throws {
        for event in try getOldEvents() {
            modelContext.delete(event)
        }
        
        try modelContext.save()
    }
    
    func getRecentEvents(interval: Double) throws -> [AppEventLog] {
        let interval = Date().addingTimeInterval(interval)
        
        let descriptor = FetchDescriptor(predicate: #Predicate<AppEventLog> { $0.timestamp >= interval }, sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        return try modelContext.fetch(descriptor)
    }
    
    func getOldEvents() throws -> [AppEventLog] {
        let threeDaysAgo = Date().addingTimeInterval(-259200)
        
        let descriptor = FetchDescriptor(predicate: #Predicate<AppEventLog> { $0.timestamp <= threeDaysAgo })
        return try modelContext.fetch(descriptor)
    }
}

extension CoreAppActor { //MARK: Sending Events
    
    func createEventPackage(interval: Double, userID: PersistentIdentifier) throws {
        let date = Date().addingTimeInterval(interval)

        var log = 
        """
        <---Events Beginning at \(date.toString(format: "MMM d, h:mm a"))--->
        Submitted on \(Date().toString(format: "MMM d, h:mm a"))
        
        """
        for event in try getRecentEvents(interval: interval) {
            log.append(event.toErrorText())
        }
        
        let package = EventPackage(log: log)
        modelContext.insert(package)
        package.user = modelContext.model(for: userID) as? CoreUser
        
        if NetworkTracker.isConnected {
            package.send()
        }
        
        try modelContext.save()
    }
    
    private func getNotExportedEventPackages() throws -> [EventPackage] {
        let descriptor = FetchDescriptor<EventPackage>()
        return try modelContext.fetch(descriptor)
    }
    
    func attemptSendEventPackages() throws {
        for package in try getNotExportedEventPackages() {
            package.send()
            Core.makeEvent("crash log uploaded", type: .log)
        }
        
        try modelContext.save()
    }
}

extension CoreAppActor { //MARK: Errors
    
    public func createError(error: Error, additionalInfo: String? = nil, userId: PersistentIdentifier) -> PersistentIdentifier {
        let error = AppError.create(error: error, additionalInfo: additionalInfo, in: modelContext)
        error.events = try? getRecentEvents(interval: -900)
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
        log.events = try? getRecentEvents(interval: -900)
        
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
