//
//  ViewExtensions.swift
//
//
//  Created by Vladislav on 7/11/24.
//

import SwiftUI

public extension View {
    var networkTracker: some View {
        modifier(NetworkTrackerModifier())
    }
    
    var popouts: some View {
        self.popoutPresenter
    }
    
    func logViewLifecycle(extendedEventName: String? = nil, parameters: [String: Any]? = nil) -> some View {
        self.modifier(AnalyticsModifier(extendedEventName: extendedEventName, parameters: parameters))
    }
}
