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
    
    public var isCompassPresented = true
    
    public var floatingSidebar = true
    public var isFloatingSidebarPresented = true
    
    private var compassAlignmentValue = "topTrailing"
    
    public init() {}
}

public extension CoreAppUI {
    
    var compassAlignment: Alignment {
        get {
            alignment(from: compassAlignmentValue)
        }
        set {
            compassAlignmentValue = text(from: newValue)
        }
    }
    
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
