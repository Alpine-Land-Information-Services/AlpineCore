//
//  ToolbarButton.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 3/12/24.
//

import SwiftData

@Model
public class ToolbarButton {
    
    public var icon: String
    public var title: String
    public var action: ToolbarAction
    public var actionValue: String?
    public var isEnabled = true
    public var sortIndex: Int
    
    public init(icon: String, title: String, action: ToolbarAction, actionValue: String? = nil, sortIndex: Int) {
        self.icon = icon
        self.title = title
        self.action = action
        self.actionValue = actionValue
        self.sortIndex = sortIndex
    }
}
