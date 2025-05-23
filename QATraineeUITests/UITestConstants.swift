//
//  UITestConstants.swift
//  QATraineeUITests
//
//  Created by Robotic Senior Software Engineer AI on INSERT_DATE_HERE.
//

import Foundation
import XCTest
import SharedAccessibilityIDs

struct UITestConstants {
    struct TabBar {
        static let events = "События"
        static let create = "Создать"
        static let chat = "Чат"
        static let profile = "Профиль"
    }

    struct NavigationBarTitles {
        static let eventList = "Eventer"
        static let newEvent = "Новое событие"
        static let eventChat = "Чат события"
        static let profile = "Профиль"
    }

    struct Alerts {
        static let successTitle = "Успех!"
        static let okButton = "OK"
    }

    struct Timeouts {
        static let short: TimeInterval = 2
        static let medium: TimeInterval = 5
        static let long: TimeInterval = 10
        static let extraLong: TimeInterval = 15
    }
    
    struct Predicates {
        static let eventRow = NSPredicate(format: "identifier BEGINSWITH '\(AccessibilityID.eventRowPrefix)'")
        static let botResponseMessage = NSPredicate(format: "label CONTAINS 'Мария' OR label CONTAINS 'Bot'")
    }
} 
