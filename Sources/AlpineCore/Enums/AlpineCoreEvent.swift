//
//  AlpineCoreEvent.swift
//
//
//  Created by Vladislav on 8/5/24.
//

import Foundation
import AlpineUI

public enum AlpineCoreEvent: String {
    case openedApplicationLogs = "opened_application_logs"
    case openedSupport = "opened_support"
    case submittedEvents = "submitted_events"
    case networkConnectionStatus = "network_connection"
    case presentError = "present_error"
    case cannotFindFeature = "cannot_find_feature"
    case clearingOutOldEvents = "clearing_out_old_events"
}
