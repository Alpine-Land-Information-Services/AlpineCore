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

struct UISafeAreaSize: EnvironmentKey {
    static let defaultValue: CGSize = .zero
}

public extension EnvironmentValues {
    var uiOrientation: UIOrientation {
        get { self[UIOrientationInfoKey.self] }
        set { self[UIOrientationInfoKey.self] = newValue }
    }
    
    var uiSafeArea: CGSize {
        get { self[UISafeAreaSize.self] }
        set { self[UISafeAreaSize.self] = newValue }
    }
}

struct InterfaceOrientation: ViewModifier {
    
    @State private var uiOrientation: UIOrientation = .unknown
    @State private var size: CGSize = .zero

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geometry in
                    Rectangle()
                        .fill(.clear)
                        .onAppear {
                            getOrientation(from: geometry)
                            size = geometry.size
                        }
                        .onChange(of: geometry.size) { _, newValue in
                            getOrientation(from: geometry)
                            size = newValue
                        }
                }
                .ignoresSafeArea(.keyboard)
            }
            .environment(\.uiOrientation, uiOrientation)
            .environment(\.uiSafeArea, size)
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

