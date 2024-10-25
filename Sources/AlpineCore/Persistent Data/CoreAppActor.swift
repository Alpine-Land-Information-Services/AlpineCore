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
    
    @MainActor
    init(container modelContainer: ModelContainer) {
        try? modelContainer.mainContext.save()
        
        self.modelContainer = modelContainer
        let context = ModelContext(modelContainer)
        modelExecutor = DefaultSerialModelExecutor(modelContext: context)
    }
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        let context = ModelContext(modelContainer)
        modelExecutor = DefaultSerialModelExecutor(modelContext: context)
    }
    
    func initialize(persistentID: PersistentIdentifier, userID: String) {
        self.user = try? modelContext.getCoreUser(id: persistentID)
        
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
        do {
            try modelContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}

extension CoreAppActor { //MARK: Events
    
    func createEvent(_ event: String, type: AppEventType, userID: String, rawParameters: [String: Any]? = nil) async {
        let eventLog = AppEventLog(event, type: type, userID: userID, rawParameters: rawParameters)
        modelContext.insert(eventLog)
        save()
    }
    
    private func clearOldEvents() throws {
        let oldEvents = try modelContext.getOldEvents()
        if !oldEvents.isEmpty {
            Core.logCoreEvent(.clearingOutOldEvents, type: .system, parameters: ["oldEvents count" : "\(oldEvents.count)"])
            for event in oldEvents {
                modelContext.delete(event)
            }
        }
    }

}

extension CoreAppActor { //MARK: Sending Events
    
    func createEventPackage(interval: Double, persistentID: PersistentIdentifier) throws {
        let date = Date().addingTimeInterval(interval)

        var log = 
        """
        ### 📅 Events
        Beginning at \(date.toString(format: "MMM d, h:mm a"))
        Submitted on \(Date().toString(format: "MMM d, h:mm a"))
        """
        for event in try modelContext.getRecentEvents(interval: interval) {
            log.append(event.toErrorText())
        }
        
        let package = EventPackage(log: log)
        modelContext.insert(package)
        package.user = try? modelContext.getCoreUser(id: persistentID)
        
        if NetworkTracker.isConnected {
            package.send()
        }
        
        save()
    }
    
    private func getNotExportedEventPackages() throws -> [EventPackage] {
        let descriptor = FetchDescriptor<EventPackage>()
        return try modelContext.fetch(descriptor)
    }
    
    func attemptSendEventPackages() throws {
        for package in try getNotExportedEventPackages() {
            package.send()
            Core.logCoreEvent(.crashLogUploaded, type: .log)
        }
        
        save()
    }
}

extension CoreAppActor { //MARK: Errors
    
    public func createError(error: Error, errorTag: String? = nil, additionalInfo: String? = nil, persistentID: PersistentIdentifier) -> PersistentIdentifier {
        let error = AppError.create(error: error, errorTag: errorTag, additionalInfo: additionalInfo, in: modelContext)
        error.events = try? modelContext.getRecentEvents(interval: -900)
        let user = try? modelContext.getCoreUser(id: persistentID)
        user?.errors.append(error)
        save()
        return error.persistentModelID
    }
    
    func attemptSendPendingErrors() throws {
        for error in try modelContext.getPendingErrors() {
            error.send()
            Core.logCoreEvent(.errorLogUploaded, type: .log)
        }
    }
}
