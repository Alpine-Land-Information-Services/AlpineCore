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
                case false:
                    return
                }
            }
    }
    
    func onConnection() {
        Core.shared.sendPendingLogs()
    }
}

public extension View {
    
    var networkTracker: some View {
        modifier(NetworkTrackerModifier())
    }
}
