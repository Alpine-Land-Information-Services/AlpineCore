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
}
