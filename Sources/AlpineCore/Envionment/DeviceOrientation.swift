//
//  DeviceOrientation.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 1/23/24.
//

import SwiftUI

struct OrientationInfoKey: EnvironmentKey {
    static let defaultValue: UIDeviceOrientation = .unknown
}

public extension EnvironmentValues {
    var deviceOrientation: UIDeviceOrientation {
        get { self[OrientationInfoKey.self] }
        set { self[OrientationInfoKey.self] = newValue }
    }
}

struct DeviceOrientationViewModifier: ViewModifier {
    
    @State private var orientation = UIDevice.current.orientation
    @State private var orientationChangePublisher = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)

    func body(content: Content) -> some View {
        content
            .environment(\.deviceOrientation, orientation)
            .onReceive(orientationChangePublisher) { _ in
                self.orientation = UIDevice.current.orientation
            }
    }
}

public extension View {
    func trackDeviceOrientation() -> some View {
        self.modifier(DeviceOrientationViewModifier())
    }
}
