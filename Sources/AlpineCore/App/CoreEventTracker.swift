//
//  CoreEventTracker.swift
//  
//
//  Created by Vladislav on 8/7/24.
//

import Foundation
import AlpineUI

public class CoreEventTracker: UIEventTracker {
    public func logEvent(_ event: String, parameters: [String: Any]?) {
        CoreAppControl.logFirebaseEvent(event, parameters: parameters)
    }
}
