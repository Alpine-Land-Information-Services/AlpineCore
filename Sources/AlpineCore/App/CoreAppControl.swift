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

@Observable
public class CoreAppControl {
    
    public static var shared = CoreAppControl()
    
    public var user: CoreUser? // IN MAIN CONTEXT
    public var app: CoreApp? // IN MAIN CONTEXT
    public var uploader: DBUploader?
    public var defaultUserID: String?
    public var defaults = CoreDefaults()
    public var firebaseEventLogger: ((_ event: String, _ parameters: [String: Any]?) -> Void)?
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
    
    private var dateInit = Date()
    private var defaultContainerName: String?
    private var defaultAppName: String?
    private var actor: CoreAppActor
    
    private init() {
        actor = CoreAppActor(modelContainer: modelContainer)
        NetworkTracker.shared.start()
    }
    
    public func assignUser(_ user: CoreUser) {
        self.user = user
        
        Task(priority: .high) { @MainActor [weak self] in
            await self?.actor.initialize(user: user.persistentModelID, userID: user.id)
        }
    }
}

public extension CoreAppControl {
    
    static var user: CoreUser! {
        Core.shared.user
    }
    
    static func quit() {
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

extension CoreAppControl {  //MARK: Events
    
    /// Logs a deprecated event using the previous `makeEvent` method.
    ///
    /// This method logs an event but is deprecated in favor of using the `logCoreEvent`, `logUIEvent`, or
    /// your framework's specific logging function.
    ///
    /// - Parameters:
    ///   - event: The event name as a `String`.
    ///   - type: The type of the event as an `AppEventType`.
    ///   - parameters: An optional dictionary of parameters associated with the event. Defaults to `nil`.
    ///   - fileInfo: An optional string containing file information. Defaults to `nil`.
    ///   - file: The name of the file from which the function is called. Defaults to the file where the function is called.
    ///   - function: The name of the function from which the function is called. Defaults to the function where the function is called.
    ///   - line: The line number from which the function is called. Defaults to the line where the function is called.
    @available(*, deprecated, message: "Use the logCoreEvent(...), logUIEvent(...) or your framework's funtion. ")
    public static func makeEvent(_ event: String,
                                 type: AppEventType,
                                 parameters: [String: Any]? = nil,
                                 fileInfo: String? = nil,
                                 file: String = #file,
                                 function: String = #function,
                                 line: Int = #line) {
        
        Self.shared.logEvent(event, type: type.rawValue, parameters: parameters, fileInfo: fileInfo, file: file, function: function, line: line)
    }
    
    /// Logs an event of type `AlpineCoreEvent` to Firebase Analytics.
    ///
    /// This method uses `logCoreEvent` to send the event to Firebase Analytics. The event is specified
    /// using the `AlpineCoreEvent` enumeration and can be accompanied by optional parameters.
    ///
    /// - Parameters:
    ///   - event: The event to be logged, from the `AlpineCoreEvent` enumeration.
    ///   - type: An optional type of the event, from the `AppEventType` enumeration. Defaults to `nil`.
    ///   - fileInfo: An optional string containing file information. Defaults to `nil`.
    ///   - parameters: An optional dictionary of parameters associated with the event. Defaults to `nil`.
    ///   - file: The name of the file from which the function is called. Defaults to the file where the function is called.
    ///   - function: The name of the function from which the function is called. Defaults to the function where the function is called.
    ///   - line: The line number from which the function is called. Defaults to the line where the function is called.
    ///
    /// - Example:
    ///   ```swift
    ///   Core.logCoreEvent(.createdSiteCalling, parameters: ["key": "value"])
    ///   ```
    ///
    /// - Note:
    ///   Ensure that the `AlpineCoreEvent` enumeration includes all possible events you want to log.
    public static func logCoreEvent(_ event: AlpineCoreEvent, extendedEventName: String? = nil, type: AppEventType? = nil, parameters: [String: Any]? = nil,
                                    fileInfo: String? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        let eventName = extendedEventName != nil ? "\(event.rawValue)_\(extendedEventName!.toSnakeCase())" : event.rawValue
        Self.shared.logEvent(eventName, type: type?.rawValue, parameters: parameters, fileInfo: fileInfo, file: file, function: function, line: line)
    }
    
    /// Logs a UI event of type `AlpineUI.UIEvent` to Firebase Analytics.
    ///
    /// This method logs a UI event `from AlpineUI`, adding the event action type to the parameters, and sends it to Firebase Analytics.
    ///
    /// - Parameters:
    ///   - event: The event to be logged, from the `AlpineUI.UIEvent` enumeration.
    ///   - typ: The type of UI event, from the `UIEventType` enumeration. Defaults to `.presses`.
    ///   - fileInfo: An optional string containing file information. Defaults to `nil`.
    ///   - parameters: An optional dictionary of parameters associated with the event. Defaults to `nil`.
    ///   - file: The name of the file from which the function is called. Defaults to the file where the function is called.
    ///   - function: The name of the function from which the function is called. Defaults to the function where the function is called.
    ///   - line: The line number from which the function is called. Defaults to the line where the function is called.
    public static func logUIEvent(_ event: AlpineUIEvent, extendedEventName: String? = nil, typ: UIEventType? = .presses, fileInfo: String? = nil, parameters: [String: Any]? = nil,
                                  file: String = #file, function: String = #function, line: Int = #line) {
        
        let eventName = extendedEventName != nil ? "\(event.rawValue)_\(extendedEventName!.toSnakeCase())" : event.rawValue
        var updatedParameters = parameters ?? [:]
        updatedParameters["eventActionType"] = typ?.rawValue
        
        Self.shared.logEvent(eventName, type: AppEventType.userAction.rawValue, parameters: updatedParameters, fileInfo: fileInfo, file: file, function: function, line: line)
    }
    
    /// Logs a generic event.
    ///
    /// This method logs a generic event by sending it to Firebase Analytics and potentially other logging mechanisms.
    ///
    /// - Parameters:
    ///   - event: The event name as a `String`.
    ///   - type: An optional type of the event as a `String`. Defaults to `nil`.
    ///   - parameters: An optional dictionary of parameters associated with the event. Defaults to `nil`.
    ///   - fileInfo: An optional string containing file information. Defaults to `nil`.
    ///   - file: The name of the file from which the function is called. Defaults to the file where the function is called.
    ///   - function: The name of the function from which the function is called. Defaults to the function where the function is called.
    ///   - line: The line number from which the function is called. Defaults to the line where the function is called.
    public static func logEvent(_ event: String, type: String? = nil, parameters: [String: Any]? = nil, fileInfo: String? = nil,
                                file: String = #file, function: String = #function, line: Int = #line) {
        Self.shared.logEvent(event, type: type, parameters: parameters, fileInfo: fileInfo, file: file, function: function, line: line)
    }
    
    /// Logs a Firebase Analytics event.
    ///
    /// This method logs an event to Firebase Analytics. The event is specified by a string and can be
    /// accompanied by optional parameters.
    ///
    /// - Parameters:
    ///   - event: The name of the event to be logged.
    ///   - parameters: An optional dictionary of parameters associated with the event. Defaults to `nil`.
    ///
    /// - Example:
    ///   ```swift
    ///   Core.logFirebaseEvent("user_signup", parameters: ["method": "email"])
    ///   ```
    public static func logFirebaseEvent(_ event: String, parameters: [String: Any]? = nil) {
        Self.shared.logFirebaseEvent(event, parameters: parameters)
    }
    
    
    /// Logs an event with detailed metadata.
    ///
    /// This private method is responsible for logging an event, including detailed metadata such as file information, function name, and line number.
    ///
    /// - Parameters:
    ///   - event: The event name as a `String`.
    ///   - type: An optional type of the event as a `String`. Defaults to `nil`.
    ///   - parameters: An optional dictionary of parameters associated with the event. Defaults to `nil`.
    ///   - fileInfo: An optional string containing file information. Defaults to `nil`.
    ///   - file: The name of the file from which the function is called. Defaults to the file where the function is called.
    ///   - function: The name of the function from which the function is called. Defaults to the function where the function is called.
    ///   - line: The line number from which the function is called. Defaults to the line where the function is called.
    private func logEvent(_ event: String, type: String? = nil, parameters: [String: Any]? = nil, fileInfo: String? = nil,
                          file: String = #file, function: String = #function, line: Int = #line) {
        
        var updatedParameters = parameters ?? [:]
        
        //TODO: - Finalize the targeting ("appTarget") definition for frameworks and packages
//       let currentBundle = Bundle(for: BundleCheck.self)
//       updatedParameters["appTarget"] = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Unknown Target"
        
        updatedParameters["fileInfo"] = "[\(URL(fileURLWithPath: file).lastPathComponent):\(line)] \(function)"
        updatedParameters["eventType"] = type
        
        logFirebaseEvent(event, parameters: updatedParameters)
        log(event)
        
        guard let user, let type, let appType = AppEventType(rawValue: type) else { return }
        
        recordAppEvent(event, type: appType, userID: user.id, rawParameters: updatedParameters)
    }
    
    
    /// Logs a Firebase Analytics event with optional parameters.
    ///
    /// This private method logs an event to Firebase Analytics using a provided logger function if available.
    /// The event is specified by a string and can be accompanied by optional parameters.
    ///
    /// - Parameters:
    ///   - event: The name of the event to be logged.
    ///   - parameters: An optional dictionary of parameters associated with the event.
    private func logFirebaseEvent(_ event: String, parameters: [String: Any]?) {
        if let firebaseEventLogger {
            firebaseEventLogger(event, parameters)
        }
    }
    
    /// Records an application event in the event log.
    ///
    /// This private method is responsible for recording an event in the application's event log, including user-related information.
    ///
    /// - Parameters:
    ///   - event: The event name as a `String`.
    ///   - type: The type of the event as an `AppEventType`.
    ///   - userID: The user ID associated with the event.
    ///   - rawParameters: An optional dictionary of raw parameters associated with the event. Defaults to `nil`.
    private func recordAppEvent(_ event: String, type: AppEventType, userID: String, rawParameters: [String: Any]? = nil) {
       
        Task(priority: .background) { [weak self] in
            var updatedParameters = rawParameters
            updatedParameters?.removeValue(forKey: "eventType")
            
            await self?.actor.createEvent(event, type: type, userID: userID, rawParameters: updatedParameters)
        }
    }
    
    /// Logs a message to the system logger.
    ///
    /// This private method logs a message to the system logger using the specified log level and event type.
    ///
    /// - Parameters:
    ///   - message: The message to log.
    ///   - strType: An optional string representing the type of the message. Defaults to `nil`.
    ///   - type: The type of the event as an `AppEventType`. Defaults to `.log`.
    ///   - level: The log level to use for the message. Defaults to `.info`.
    private func log(_ message: String, strType: String? = nil, type: AppEventType = .log, level: OSLogType = .info) {
        guard let subSystem = Bundle.main.bundleIdentifier else { return }
        let logger = Logger(subsystem: subSystem, category: strType ?? type.rawValue)
        logger.log(level: level, "\(message)")
    }
    
}

extension CoreAppControl { //MARK: Actor
    
    private func saveActor() {
        Task(priority: .background) { [weak self] in
            await self?.actor.save()
        }
    }
    
    func createEventPack(interval: Double) {
        guard let user else { return }
        Core.makeSimpleAlert(title: "Events Submitted", message: "Thank you, your event logs will be sent to developer.")
        Task(priority: .background) { [weak self] in
            try? await self?.actor.createEventPackage(interval: interval, userID: user.persistentModelID)
        }
    }
}

extension CoreAppControl { //MARK: Errors
    
    /// Sets the default error parameters for the CoreAppControl.
    ///
    /// This method sets default parameters that are used when handling errors within the app. These parameters
    /// include the container name, application name, user ID, and an optional token for the uploader.
    ///
    /// - Parameters:
    ///   - containerName: The name of the default container to be used when handling errors. Defaults to `nil`.
    ///   - appName: The name of the application. Defaults to `nil`.
    ///   - userID: The default user ID to be used when handling errors. Defaults to `nil`.
    ///   - token: An optional token to be used by the uploader. Defaults to `nil`.
    public func setDefaultErrorParameters(containerName: String? = nil, appName: String? = nil, userID: String? = nil, token: String? = nil) {
        self.defaultContainerName = containerName
        self.defaultAppName = appName
        self.defaultUserID = userID
        self.uploader = DBUploader(token: token ?? "")
    }
    
    
    /// Handles an error within the CoreAppControl, creating an error log and optionally presenting it to the user.
    ///
    /// This static method processes the provided error, generates an error log, and can present the error to the user
    /// with the option to report it. It ensures that the error is logged with relevant details and associated
    /// with the current user.
    ///
    /// - Parameters:
    ///   - error: The error to be handled.
    ///   - errorTag: An optional tag to identify the error. Defaults to `nil`.
    ///   - additionalInfo: Additional information to include in the error log. Defaults to `nil`.
    ///   - showToUser: A Boolean value indicating whether the error should be presented to the user. Defaults to `true`.
    public static func makeError(error: Error, additionalInfo: String? = nil, showToUser: Bool = true) {
        Self.shared.makeError(error: error, additionalInfo: additionalInfo, showToUser: showToUser)
    }
    
    /// Handles an error within the CoreAppControl, creating an error log and optionally presenting it to the user.
    ///
    /// This method processes the provided error, generates an error log, and can present the error to the user
    /// with the option to report it. It ensures that the error is logged with relevant details and associated
    /// with the current user.
    ///
    /// - Parameters:
    ///   - error: The error to be handled.
    ///   - errorTag: An optional tag to identify the error. Defaults to `nil`.
    ///   - additionalInfo: Additional information to include in the error log. Defaults to `nil`.
    ///   - showToUser: A Boolean value indicating whether the error should be presented to the user. Defaults to `true`.
    private func makeError(error: Error,
                           errorTag: String? = nil,
                           additionalInfo: String? = nil,
                           showToUser: Bool = true) {
        let errorTag = AppError.generateErrorTag()
        
        Task {
            await Self.shared.processErrorFiles(error: error, errorTag: errorTag)
            Self.shared.createError(error: error, errorTag: errorTag, additionalInfo: additionalInfo, showToUser: showToUser)
        }
    }
    
    /// Processes the provided error and handles the necessary tasks to log and present the error to the user.
    ///
    /// This private method ensures the error is logged and provides the user with a report option if the error is presented
    /// to them. It also handles the cleanup of error files after the error is presented.
    ///
    /// - Parameters:
    ///   - error: The error to be processed.
    ///   - errorTag: An optional tag to identify the error. Defaults to `nil`.
    ///   - additionalInfo: Additional information to include in the error log. Defaults to `nil`.
    ///   - showToUser: A Boolean value indicating whether the error should be presented to the user. Defaults to `true`.
    private func createError(error: Error, errorTag: String? = nil, additionalInfo: String? = nil, showToUser: Bool = true) {
        guard let user else { return }
        
        Task { [weak self] in
            guard let self else { return }
            
            let errorID = await actor.createError(error: error, errorTag: errorTag, additionalInfo: additionalInfo, userId: user.persistentModelID)
            
            if showToUser {
                await self.presentErrorToUser(error: error, errorID: errorID, errorTag: errorTag)
            }
        }
    }
    
    /// Presents the error to the user with an option to report it.
    ///
    /// This private method presents the error to the user and provides an option to report the error if it is of a
    /// certain type. It also performs cleanup of error files once the user acknowledges the error.
    ///
    /// - Parameters:
    ///   - error: The error to be presented to the user.
    ///   - errorID: The identifier of the error that was logged.
    ///   - errorTag: An optional tag to identify the error. Defaults to `nil`.
    private func presentErrorToUser(error: Error, errorID: PersistentIdentifier, errorTag: String?) async {
        let (title, message) = self.getErrorText(error: error, errorTag: errorTag)
//        Core.logCoreEvent(.presentError, type: .error, parameters: ["title" : "\(title)", "message":"\(message)"])
        Core.logCoreEvent(.presentError, type: .error)
        let okButton = AlertButton(title: "Okay", style: .default, action: {
            try? self.uploader?.cleanupErrorFilesFolder(folderTag: errorTag)
        })
        
        if message.contains("socketError") || message.contains("connectionClosed") {
            DispatchQueue.main.async {
                Core.makeAlert(CoreAlert(title: "Connection Error", message: "Server could not be reached now.\nPlease try again later.", buttons: [okButton]))
            }
            return
        }
        
        let reportButton = await self.createReportButton(for: errorID)
        
        DispatchQueue.main.async {
            Core.makeAlert(CoreAlert(title: title, message: message, buttons: [okButton, reportButton]))
        }
    }
    
    /// Creates a report button that allows the user to report the error.
    ///
    /// This method creates a button that, when pressed, allows the user to report the error. The button is linked to
    /// the error ID that was generated when the error was logged.
    ///
    /// - Parameter errorID: The identifier of the error that was logged.
    /// - Returns: A `CoreAlertButton` that allows the user to report the error.
    @MainActor
    private func createReportButton(for errorID: PersistentIdentifier) async -> CoreAlertButton {
        return CoreAlertButton(title: "Report", style: .default) { [weak self] in
            guard let self else { return }
            
            if let error = self.modelContainer.mainContext.model(for: errorID) as? AppError {
                self.presentSupportContactView(for: error)
            } else {
                Core.makeSimpleAlert(title: "Something Went Wrong", message: "Could not find error by specified ID to send.")
            }
        }
    }
    
    /// Presents the support contact view for the error.
    ///
    /// This method presents a view that allows the user to contact support regarding the error.
    ///
    /// - Parameter error: The `AppError` instance to be reported.
    private func presentSupportContactView(for error: AppError) {
        Core.presentSheet {
            NavigationStack {
                SupportContactView(userID: error.user?.id ?? "_NO_USER_ID_", supportType: .bug, associatedError: error)
                    .toolbar(content: {
                        DismissButton(onEvent: { event, parameters in
                            Core.logUIEvent(.dismissButton)
                        })
                    })
            }
        }
    }
    
    /// Retrieves the title and message text for the error based on its type.
    ///
    /// This method generates the title and message to display for the given error, optionally including an error
    /// reference code.
    ///
    /// - Parameters:
    ///   - error: The error to be presented.
    ///   - errorTag: An optional tag to identify the error.
    /// - Returns: A tuple containing the title and message text for the error.
    private func getErrorText(error: Error, errorTag: String?) -> (String, String) {
        if let err = error as? AlpineError {
            return (err.getType(), err.message)
        }
        return ("System Error", error.log())
    }
    
    /// Processes the files associated with an error.
    ///
    /// This method processes and moves files associated with an error, archiving them for further analysis.
    ///
    /// - Parameters:
    ///   - error: The error to process.
    ///   - errorTag: The tag used to identify the error files.
    private func processErrorFiles(error: Error, errorTag: String) async {
        guard let defaultContainerName , let defaultAppName, let defaultUserID else { return }
        if let err = error as? AlpineError {
            for type in err.includedFile {
                switch type {
                case .userAppContainer:
                    _ = try? await uploader?.archiveAndMoved(containerPath: "\(defaultContainerName)", to: errorTag, containerType: .appData)
                case .fileSystemContainer:
                    _ = try? await uploader?.archiveAndMoved(containerPath: "Atlas File System.store", to: errorTag, containerType: .filesystem)
                case .userDataContainer:
                    _ = try? await uploader?.archiveAndMoved(containerPath: "Atlas User Data.store", to: errorTag, containerType: .userData)
                case .mapDataDataContainer:
                    _ = try? await uploader?.archiveAndMoved(containerPath: "\(defaultUserID)/\(defaultAppName)", to: errorTag, containerType: .mapData)
                case .file(path: let path):
                    _ = try? await uploader?.archiveAndMoved(containerURL: path, to: errorTag, fileName: nil)
                }
            }
        }
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
