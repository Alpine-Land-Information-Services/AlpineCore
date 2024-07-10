//
//  String.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/17/23.
//

import Foundation

public extension String {
    
    var fsPath: FSPath {
        FSPath(rawValue: self)
    }
    
}
