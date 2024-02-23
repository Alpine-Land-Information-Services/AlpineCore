//
//  CoreAppUI.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 2/16/24.
//

import SwiftUI
import SwiftData

@Model
public class CoreAppUI {
    
    public var isCompassPresented = false
    
    public var landscapeSidebarOverlay = false
    public var floatingNavigation = false
    public var floatingNavigationAlignment = "topLeading"
    
    public var compassAlignment = "topTrailing"
    public var borderedButtonStyle = true
    
    public init() {}
}

public extension CoreAppUI {
    
    func alignment(from text: String) -> Alignment {
        switch text {
        case "topLeading":
            return .topLeading
        case "top":
            return .top
        case "topTrailing":
            return .topTrailing
        case "leading":
            return .leading
        case "center":
            return .center
        case "trailing":
            return .trailing
        case "bottomLeading":
            return .bottomLeading
        case "bottom":
            return .bottom
        case "bottomTrailing":
            return .bottomTrailing
        default:
            return .center // Default or fallback alignment
        }
    }
    
    func text(from alignment: Alignment) -> String {
        switch alignment {
        case .topLeading:
            return "topLeading"
        case .top:
            return "top"
        case .topTrailing:
            return "topTrailing"
        case .leading:
            return "leading"
        case .center:
            return "center"
        case .trailing:
            return "trailing"
        case .bottomLeading:
            return "bottomLeading"
        case .bottom:
            return "bottom"
        case .bottomTrailing:
            return "bottomTrailing"
        default:
            return "center" // Default or fallback text
        }
    }
}
