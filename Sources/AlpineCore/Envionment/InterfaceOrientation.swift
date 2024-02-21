//
//  InterfaceOrientation.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 1/23/24.
//

import SwiftUI

public enum UIOrientation {
    case landcape
    case portrait
    case unknown
    
    public var isPortrait: Bool {
        self == .portrait
    }
    
    public var isLandscape: Bool {
        self == .landcape
    }
}

struct UIOrientationInfoKey: EnvironmentKey {
    static let defaultValue: UIOrientation = .unknown
}

public extension EnvironmentValues {
    var uiOrientation: UIOrientation {
        get { self[UIOrientationInfoKey.self] }
        set { self[UIOrientationInfoKey.self] = newValue }
    }
}

struct InterfaceOrientation: ViewModifier {
    
    @State private var uiOrientation: UIOrientation = .unknown

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geometry in
                    Rectangle()
                        .fill(.clear)
                        .onAppear {
                            getOrientation(from: geometry)
                        }
                        .onChange(of: geometry.size) { _, _ in
                            getOrientation(from: geometry)
                        }
                }
                .ignoresSafeArea()
                .ignoresSafeArea(.keyboard)
            }
            .environment(\.uiOrientation, uiOrientation)
    }
    
    private func getOrientation(from geometry: GeometryProxy) {
        if geometry.size.width > geometry.size.height {
            uiOrientation = .landcape
        }
        else {
            uiOrientation = .portrait
        }
    }
}

public extension View {
    
    var uiOrientationGetter: some View {
        modifier(InterfaceOrientation())
    }
}

