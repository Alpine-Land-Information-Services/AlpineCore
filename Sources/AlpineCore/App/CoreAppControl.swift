//
//  CoreAppControl.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 1/18/24.
//

import SwiftUI
import SwiftData
import OSLog

import PopupKit
import AlpineUI

public typealias Core = CoreAppControl
public typealias CoreAlert = SceneAlert
public typealias CoreAlertButton = AlertButton

@Observable
public class CoreAppControl {
    
    public static var shared = CoreAppControl()
    
    public let modelContainer: ModelContainer = {
        let schema = Schema([CoreUser.self, AppEventLog.self])
        let modelConfiguration = ModelConfiguration("Core App Data", schema: schema, groupContainer: .none)
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var actor: CoreAppActor
    private var dateInit = Date()
    
    public var user: CoreUser? // IN MAIN CONTEXT
    public var app: CoreApp? // IN MAIN CONTEXT
    
    public var defaults = CoreDefaults()
    
    public var appEventAdder: ((_ event: String, _ type: AppEventType) -> Void)?

    private init() {
        actor = CoreAppActor(modelContainer: modelContainer)
        NetworkTracker.shared.start()
    }
    
    public func assignUser(_ user: CoreUser) {
        self.user = user

        Task(priority: .high) { [weak self] in
            await self?.actor.initialize(user: user.persistentModelID, userID: user.id)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.checkForCrash()
        }
    }
    
    private func checkForCrash() {
        let lastLaunch = defaults.lastAppLaunch
        defaults.lastAppLaunch = dateInit

//        #if !DEBUG
//        if user?.isActive ?? false {
//            promptToCreateCrashLog(lastLaunch: lastLaunch)
//        }
//        #endif
        markActive()
    }
    
    
    public func markActive() {
        user?.isActive = true
        try? user?.modelContext?.save()
    }
    
    public func markInactive() {
        user?.isActive = false
        try? user?.modelContext?.save()
    }
}

public extension CoreAppControl {
    
    static var user: CoreUser! {
        Core.shared.user
    }
    
    static func quit() {
        Core.shared.markInactive()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exit(0)
        }
    }
    
    static func reset() {
        CoreAppControl.shared = CoreAppControl()
    }
}

public extension CoreAppControl { //MARK: Init
    
    func sendPendingLogs() {
        guard let user else { return }
        
        Task(priority: .background) { [weak self] in
            await self?.actor.sendPendingLogs(userID: user.id)
        }
    }
    
    func setInitialized(to value: Bool, sandbox: Bool) {
        switch sandbox {
        case true:
            defaults.isSandboxInitialized = value
        case false:
            defaults.isInitialized = value
        }
    }
    
    func isInitialized(sandbox: Bool) -> Bool {
        switch sandbox {
        case true:
            defaults.isSandboxInitialized
        case false:
            defaults.isInitialized
        }
    }
}

extension CoreAppControl { //MARK: Crashes
    
    func promptToCreateCrashLog(lastLaunch: Date?) {
        Core.presentSheet {
            CrashLogSubmitView(lastLuanch: lastLaunch)
        }
    }
    
    func createCrashLog(lastLaunch: Date?, comments: String?, didNot: Bool?) {
        guard let user else { return }
        let dateInit = dateInit
        Task { [weak self] in
            await self?.actor.createCrashLog(userID: user.id, dateInit: dateInit, lastLaunch: lastLaunch, comments: comments, didNot: didNot)
        }
    }
}

extension CoreAppControl { //MARK: Events
    
    public static func makeEvent(_ event: String, type: AppEventType, hidden: Bool? = nil, secret: Bool = false, log: ((_ logger: Logger) -> Void)? = nil) {
        let isHidden = hidden ?? type.isDefaultHidden
        guard let user else { return }
        Core.shared.makeEvent(event, hidden: isHidden, secrect: secret, type: type, userID: user.id)
        
        if let log {
            guard let subSystem = Bundle.main.bundleIdentifier else { return }
            let logger = Logger(subsystem: subSystem, category: type.rawValue)
            log(logger)
        }
    }
    
    private func makeEvent(_ event: String, hidden: Bool, secrect: Bool, type: AppEventType, userID: String) {
        if let appEventAdder {
            appEventAdder(event, type)
        }
        Task(priority: .background) { [weak self] in
            await self?.actor.createEvent(event, type: type, hidden: hidden, secret: secrect, userID: userID)
        }
    }
    
    func saveActor() {
        Task(priority: .background) { [weak self] in
            await self?.actor.save()
        }
    }
    
    public static func log(_ message: String, strType: String? = nil, type: AppEventType = .log, level: OSLogType = .info) {
        guard let subSystem = Bundle.main.bundleIdentifier else { return }
        let logger = Logger(subsystem: subSystem, category: strType ?? type.rawValue)
        logger.log(level: level, "\(message)")
    }
    
    func createEventPack(interval: Double) {
        guard let user else { return }
        Core.makeEvent("submitted events", type: .userAction)
        
        Core.makeSimpleAlert(title: "Events Submitted", message: "Thank you, your event logs will be sent to developer.")
        Task(priority: .background) { [weak self] in
            try? await self?.actor.createEventPackage(interval: interval, userID: user.persistentModelID)
        }
    }
}

extension CoreAppControl { //MARK: Errors
    
    public static func makeError(error: Error, additionalInfo: String? = nil, showToUser: Bool = true) {
        Self.shared.makeError(error: error, additionalInfo: additionalInfo, showToUser: showToUser)
    }
    
    public func makeError(error: Error, additionalInfo: String? = nil, showToUser: Bool = true) {
        guard let user else { return }

        Task { [weak self] in
            guard let self else { return }
            let errorID = await actor.createError(error: error, additionalInfo: additionalInfo, userId: user.persistentModelID)
            
            if showToUser {
                DispatchQueue.main.async {
                    let (title, message) = self.getErrorText(error: error)
                    Core.makeEvent("\(title): \(message)", type: .error)
                    let reportButton = CoreAlertButton(title: "Report", style: .default) {
                        if let error = self.modelContainer.mainContext.model(for: errorID) as? AppError {
                            Core.presentSheet {
                                NavigationStack {
                                    SupportContactView(userID: error.user?.id ?? "_NO_USER_ID_", supportType: .bug, associatedError: error)
                                        .toolbar(content: {
                                            DismissButton()
                                        })
                                }
                            }
                        } else {
                            Core.makeSimpleAlert(title: "Something Went Wrong", message: "Could not find error by specified ID to send.")
                        }
                    }
                    if message.contains("socketError") || message.contains("connectionClosed") {
                        Core.makeAlert(CoreAlert(title: "Connection Error", message: "Server could not be reached now.\nPlease try again later.", buttons: [.ok]))
                        return
                    }
                    Core.makeAlert(CoreAlert(title: title, message: message, buttons: [.ok, reportButton]))
                }
            }
        }
    }
    
    private func getErrorText(error: Error) -> (String, String) {
        if let err = error as? AlpineError {
            return (err.getType(), err.message)
        }
        return ("System Error", error.log())
    }
}

public extension CoreAppControl { //MARK: Alerts
    
    static func makeAlert(_ alert: CoreAlert) {
        DispatchQueue.main.async {
            AlertManager.shared.presentAlert(alert)
        }
    }
    
    static func makeSimpleAlert(title: String?, message: String?) {
        DispatchQueue.main.async {
            let alert = CoreAlert(title: title, message: message, buttons: nil)
            AlertManager.shared.presentAlert(alert)
        }
    }
}

public extension CoreAppControl { //MARK: Sheets
    
    static func presentSheet<Content: View>(style: UIModalPresentationStyle = .automatic, @ViewBuilder _ content: @escaping () -> Content) {
        PKSheetManager.shared.presentSheet(style: style, content)
    }
    
    static func makePopout(systemImage: String, message: String) {
        PKPopoutManager.shared.makePopout(systemImage: systemImage, message: message)
    }
}
