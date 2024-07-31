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
    
    func initialize(user: PersistentIdentifier, userID: String) {
        self.user = modelContext.model(for: user) as? CoreUser
        
        Task(priority: .background) {
            sendPendingLogs(userID: userID)
            try? clearOldEvents()
        }
    }
    
    func sendPendingLogs(userID: String) {
        guard NetworkTracker.shared.isConnected else { return }
        
        try? attemptSendPendingErrors()
        try? attemptSendEventPackages()
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
        let oldEvents = try getOldEvents()
        if !oldEvents.isEmpty {
            Core.makeEvent("clearing out \(oldEvents.count) old events", type: .system)
            for event in oldEvents {
                modelContext.delete(event)
            }
            
            try modelContext.save()
        }
    }
    
    func getRecentEvents(interval: Double, from date: Date = Date()) throws -> [AppEventLog] {
        let interval = date.addingTimeInterval(interval)
        
        let descriptor = FetchDescriptor(predicate: #Predicate<AppEventLog> { $0.timestamp >= interval }, sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        return try modelContext.fetch(descriptor)
    }
    
    
    func getRecentEvents(interval: Double, from date: Date, to endDate: Date) throws -> [AppEventLog] {
        let interval = date.addingTimeInterval(interval)
        
        let descriptor = FetchDescriptor(predicate: #Predicate<AppEventLog> { $0.timestamp >= interval && $0.timestamp < endDate }, sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        
        return try modelContext.fetch(descriptor)
    }
    
    func getEvents(before dateInit: Date, limit: Int) throws -> [AppEventLog] {
        var descriptor = FetchDescriptor(predicate: #Predicate<AppEventLog> { $0.timestamp < dateInit }, sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        descriptor.fetchLimit = limit
        return try modelContext.fetch(descriptor)
    }
    
    func getPreCrashEvents(before dateInit: Date) throws -> [AppEventLog] {
        var descriptor = FetchDescriptor(predicate: #Predicate<AppEventLog> { $0.timestamp < dateInit }, sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        descriptor.fetchLimit = 1
        
        if let event = try modelContext.fetch(descriptor).first {
            return try getRecentEvents(interval: -900, from: event.timestamp, to: dateInit)
        }
        
        return []
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
        
        save()
        
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

//extension CoreAppActor { //MARK: Crashes
//    
//    public func createCrashLog(userID: String, dateInit: Date, lastLaunch: Date?, comments: String?, didNot: Bool?) {
//        let log = AppCrashLog()
//        modelContext.insert(log)
//        
//        log.comments = comments
//        log.lastDateLaunch = lastLaunch
//        log.didNotCrash = didNot
//        log.events = try? getEvents(before: dateInit, limit: 200)
//        
//        log.send(userID: userID)
//
//        save()
//    }
//    
//    func attemptSendPendingCrashes(userID: String) throws {
//        for crash in try getNotReportedCrashes() {
//            crash.send(userID: userID)
//            Core.makeEvent("crash log uploaded", type: .log)
//        }
//        
//        try modelContext.save()
//    }
//    
//    private func getNotReportedCrashes() throws -> [AppCrashLog] {
//        let descriptor = FetchDescriptor(predicate: #Predicate<AppCrashLog> { $0.reportDate == nil })
//        return try modelContext.fetch(descriptor)
//    }
//}
