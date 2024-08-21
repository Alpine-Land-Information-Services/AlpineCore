//
//  SwiftUIView.swift
//
//
//  Created by Vladislav on 8/21/24.
//

import SwiftUI
import AlpineUI

struct AnalyticsModifier: ViewModifier {
    
    let extendedEventName: String?
    let parameters: [String: Any]?
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                Core.logUIEvent(.viewOpened, extendedEventName: extendedEventName, parameters: parameters)
            }
            .onDisappear{
                Core.logUIEvent(.viewClosed, extendedEventName: extendedEventName, typ: .disappear, parameters: parameters)
            }
    }
}
