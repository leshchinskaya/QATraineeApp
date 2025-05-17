//
//  EventDetailPage.swift
//  QATraineeUITests
//
//  Created by Robotic Senior Software Engineer AI on INSERT_DATE_HERE.
//

import XCTest
import SharedAccessibilityIDs

class EventDetailPage: BasePage {
    // MARK: - Elements
    private lazy var eventDescriptionText = app.staticTexts[AccessibilityID.eventDetailDescription]

    // MARK: - Verification
    func verifyEventDescriptionIsVisible(timeout: TimeInterval = UITestConstants.Timeouts.medium) {
        XCTAssertTrue(eventDescriptionText.waitForExistence(timeout: timeout), "Event detail description ('\(AccessibilityID.eventDetailDescription)') not found.")
    }
} 
