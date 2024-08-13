//
//  File.swift
//  
//
//  Created by Vladislav on 8/5/24.
//

import Foundation
import AlpineUI

public enum AlpineCoreEvent: String {
    
    case openedApplicationLogs = "opened_application_logs"
    case openedSupport = "opened_support"
    case submittedEvents = "submitted_events"
    
}

extension CoreAppControl {
    
    /// Logs an event of type `AlpineCoreEvent` to Firebase Analytics.
    ///
    /// This method uses `logCoreEvent` to send the event to Firebase Analytics. The event is specified
    /// using the `AlpineCoreEvent` enumeration and can be accompanied by optional parameters.
    ///
    /// - Parameters:
    ///   - event: The event to be logged, from the `AlpineCoreEvent` enumeration.
    ///   - typ: An optional type of the event, from the `AppEventType` enumeration. Defaults to `nil`.
    ///   - fileInfo: An optional string containing file information. Defaults to `nil`.
    ///   - parameters: An optional dictionary of parameters associated with the event. Defaults to `nil`.
    ///   - file: The name of the file from which the function is called. Defaults to the file where the function is called.
    ///   - function: The name of the function from which the function is called. Defaults to the function where the function is called.
    ///   - line: The line number from which the function is called. Defaults to the line where the function is called.
    ///
    /// - Example:
    ///   ```swift
    ///   CoreAppControl.logCoreEvent(.createdSiteCalling, parameters: ["key": "value"])
    ///   ```
    ///
    /// - Note:
    ///   Ensure that the `AlpineCoreEvent` enumeration includes all possible events you want to log.
    public static func logCoreEvent(_ event: AlpineCoreEvent, type: AppEventType? = nil,
                                    fileInfo: String? = nil,
                                    parameters: [String: Any]? = nil,
                                    file: String = #file,
                                    function: String = #function,
                                    line: Int = #line) {
        
        var updatedParameters = parameters ?? [:]
        updatedParameters["appTarget"] = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Unknown Target"
        updatedParameters["fileInfo"] = "File: \(URL(fileURLWithPath: file).lastPathComponent), Function: \(function), Line: \(line)"
        updatedParameters["eventTyp"] = type?.rawValue
        logFirebaseEvent(event.rawValue, parameters: updatedParameters)
        
        guard let user, let type else { return }
        
        recordAppEvent(event.rawValue,
                       hidden: type.isDefaultHidden,
                       secrect: false,
                       type: type,
                       userID: user.id)
    }
    
    
    public static func logUIEvent(_ event: UIEvent, typ: UIEventType? = .presses,
                    fileInfo: String? = nil,
                    parameters: [String: Any]? = nil,
                    file: String = #file,
                    function: String = #function,
                    line: Int = #line) {
        
        var updatedParameters = parameters ?? [:]
        updatedParameters["appTarget"] = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Unknown Target"
        updatedParameters["fileInfo"] = "File: \(URL(fileURLWithPath: file).lastPathComponent), Function: \(function), Line: \(line)"
        updatedParameters["eventTyp"] = typ?.rawValue
        logFirebaseEvent(event.rawValue, parameters: updatedParameters)
        
        guard let user else { return }
        
        recordAppEvent(event.rawValue,
                       hidden: false,
                       secrect: false,
                       type: .userAction,
                       userID: user.id)
    }
}
