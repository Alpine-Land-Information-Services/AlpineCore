//
//  View.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 8/12/24.
//

import SwiftUI
import AlpineUI

public extension View {
    
    var popouts: some View {
        self.popoutPresenter
    }
    
    func logViewLifecycle(extendedEventName: String? = nil, parameters: [String: Any]? = nil) -> some View {
        self.modifier(AnalyticsModifier(extendedEventName: extendedEventName, parameters: parameters))
    }
}
