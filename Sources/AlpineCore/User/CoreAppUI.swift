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
    
    public var isCompassPresented: Bool = false
    public var landscapeSidebarOverlay: Bool = false
    public var borderedButtonStyle: Bool = true
    public var compassAlignment: String = "topTrailing"
    public var sidebarAlignmnet: String = "trailing"
    public var buttonsSize: String = "compact"
    public var toolbar: CoreUIToolbar?
    
    public init() {}
}

public extension CoreAppUI {
    
    var largeButtons: Bool {
        buttonsSize == "large"
    }
    
    var leftUI: Bool {
        sidebarAlignmnet == "trailing"
    }
    
    var panelAlignment: Alignment {
        get {
            switch sidebarAlignmnet {
            case "trailing":
                return .trailing
            default:
                return .leading
            }
        }
        set {
            switch newValue {
            case .trailing:
                sidebarAlignmnet = "trailing"
            default:
                sidebarAlignmnet = "leading"
            }
        }
    }
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

public extension CoreAppUI {
    
    var panelWidth: CGFloat {
        largeButtons ? 54 : 44
    }
    
    var sidebarWidth: CGFloat {
        300
    }
    
    var panelPadding: Edge.Set {
        leftUI ? .trailing : .leading
    }
    
    var sidebarNavAlignment: Alignment {
        leftUI ? .topLeading : .topTrailing
    }
    
    var sidebarBottomAlignmnet: Alignment {
        leftUI ? .bottomLeading : .bottomTrailing
    }
    
    var panelAlign: Alignment {
        leftUI ? .trailing : .leading
    }
    
    var panelEdge: Edge {
        leftUI ? .trailing : .leading
    }
    
    var sidebarPadding: Edge.Set {
        leftUI ? .leading : .trailing
    }
}
