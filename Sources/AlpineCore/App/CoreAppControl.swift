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
        let schema = Schema([CoreUser.self])
        let storeURL = URL.documentsDirectory.appending(path: "Core App Data.sqlite")
        let modelConfiguration = ModelConfiguration("Core App Data", schema: schema, groupContainer: .none)
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    private var actor: CoreAppActor
    
    public var user: CoreUser! // IN MAIN CONTEXT
    public var app: CoreApp! // IN MAIN CONTEXT
    
    public var defaults = CoreDefaults()
    
    private init() {
        actor = CoreAppActor(modelContainer: modelContainer)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    private func appWillTerminate() {
        defaults.isAppActive = false
    }
    
    func checkForCrash() {
        if defaults.isAppActive {
            promptToCreateCrashLog()
        }
        
        defaults.isAppActive = true
    }
}

public extension CoreAppControl {
    
    static var user: CoreUser {
        Core.shared.user
    }
    
    static func quit() {
        exit(0)
    }
}

public extension CoreAppControl { //MARK: Init
    
    func assignUser(_ user: CoreUser) {
        self.user = user
        checkForCrash()
    }
    
    static func reset() {
        CoreAppControl.shared = CoreAppControl()
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
    
    func promptToCreateCrashLog() {
        let doNot = CoreAlertButton(title: "Do Not Send", style: .cancel, action: {})
        let ok = CoreAlertButton(title: "Okay", style: .default) {
            self.createCrashLog()
        }
        let alert = CoreAlert(title: "Application Crash", message: "We detected a crash during last usage. Report will be sent to the developer to help resolve this issue as soon as possible.", buttons: [doNot, ok])
        
        Core.makeAlert(alert)
    }
    
    private func createCrashLog() {
        guard let user else { return }
        
        Task {
            await actor.createCrashLog(userID: user.persistentModelID)
        }
    }
}

extension CoreAppControl { //MARK: Events
    
    public static func makeEvent(_ event: String, type: AppEventType, log: ((_ logger: Logger) -> Void)? = nil) {
        Core.shared.makeEvent(event, type: type)
        
        if let log {
            guard let subSystem = Bundle.main.bundleIdentifier else { return }
            let logger = Logger(subsystem: subSystem, category: type.rawValue)
            log(logger)
        }
    }
    
    private func makeEvent(_ event: String, type: AppEventType) {
        Task(priority: .background) {
            await actor.createEvent(event, type: type, userID: user?.persistentModelID)
        }
    }
}

extension CoreAppControl { //MARK: Errors
    
    public static func makeError(error: Error, additionalInfo: String? = nil, showToUser: Bool = true) {
        Self.shared.makeError(error: error, additionalInfo: additionalInfo, showToUser: showToUser)
    }
    
    public func makeError(error: Error, additionalInfo: String? = nil, showToUser: Bool = true) {
        Task {
            let errorID = await actor.createError(error: error, additionalInfo: additionalInfo, userId: user.persistentModelID)
            
            if showToUser {
                DispatchQueue.main.async { [self] in
                    let (title, message) = getErrorText(error: error)
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
