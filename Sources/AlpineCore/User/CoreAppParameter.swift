//
//  CoreAppParameter.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 6/7/24.
//

import Foundation
import SwiftData

@Model
final public class CoreAppParameter {
    
    public var key: String = "_INVALID_PARAMETER_KEY_"

    public var strValue: String?
    public var intValue: Int?
    public var dataValue: Data?
    
    private init() {}
    
    public convenience init(key: String, strValue: String? = nil, intValue: Int? = nil, dataValue: Data? = nil) {
        self.init()
        
        self.strValue = strValue
        self.intValue = intValue
        self.dataValue = dataValue
    }
}
