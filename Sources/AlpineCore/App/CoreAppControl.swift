//
//  CoreAppControl.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 1/18/24.
//

import Foundation
import Observation
import SwiftData
import PopupKit

public typealias Core = CoreAppControl
public typealias CoreAlert = SceneAlert

@Observable
public class CoreAppControl {
    
    public static var shared = CoreAppControl()
    public var modelContainer: ModelContainer?
    public var user: CoreUser! // IN MAIN CONTEXT
    
    private init() {}
   
    static func makeAlert(_ alert: CoreAlert) {
        DispatchQueue.main.async {
            AlertManager.shared.presentAlert(alert)
        }
    }
    
    private func getErrorText(error: Error) -> (String, String) {
        if let err = error as? AlpineError {
            return (err.getType(), err.message)
        }
        return ("System Error", error.log())
    }
    
    public func makeError(error: Error, additionalInfo: String? = nil, showToUser: Bool = true) {
        guard let modelContainer else { return }
        Task {
            let actor = AppErrorActor(modelContainer: modelContainer)
            await actor.makeError(error: error, additionalInfo: additionalInfo, userId: user.persistentModelID)
            if showToUser {
                let (title, message) = getErrorText(error: error)
                Core.makeAlert(CoreAlert(title: title, message: message, buttons: nil))
            }
        }
    }
}
