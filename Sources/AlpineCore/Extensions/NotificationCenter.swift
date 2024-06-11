//
//  NotificationCenter.swift
//  AlpineCore
//
//  Created by mkv on 3/28/23.
//

import Foundation

public extension NotificationCenter {
    //TODO: change back to use without DispatchQueue.main.async - check function usage after it
    static func post(_ name: NSNotification.Name, _ userInfo: [AnyHashable : Any]? = nil, _ object: Any? = nil) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: name, object: object, userInfo: userInfo)
        }
    }
    
    static func postMainAsync(_ name: NSNotification.Name, _ userInfo: [AnyHashable : Any]? = nil, _ object: Any? = nil) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: name, object: object, userInfo: userInfo)
        }
    }
}
