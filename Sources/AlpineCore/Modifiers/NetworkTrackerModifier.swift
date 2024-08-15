//
//  NetworkTrackerModifier.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/17/24.
//

import SwiftUI

struct NetworkTrackerModifier: ViewModifier {
    
    var network = NetworkTracker.shared
    
    func body(content: Content) -> some View {
        content
            .onChange(of: network.isConnected) { oldValue, newValue in
                switch newValue {
                case true:
                    onConnection()
                    Core.logCoreEvent(.networkConnectionStatus, type: .system, parameters: ["status" : "resumed"])
                case false:
                    Core.logCoreEvent(.networkConnectionStatus, type: .system, parameters: ["status" : "lost"])
                    return
                }
            }
    }
    
    func onConnection() {
        Core.shared.sendPendingLogs()
    }
}

