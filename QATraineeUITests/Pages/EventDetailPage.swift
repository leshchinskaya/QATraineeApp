//
//  EventDetailPage.swift
//  QATraineeUITests
//
//  Created by Robotic Senior Software Engineer AI on INSERT_DATE_HERE.
//

import XCTest

class EventDetailPage: BasePage {
    // MARK: - Elements
    // private lazy var eventDescriptionText = app.staticTexts.matching(identifier: UITestConstants.AccessibilityID.eventDetailDescription).firstMatch
    private lazy var eventDescriptionText = app.staticTexts[UITestConstants.AccessibilityID.eventDetailDescription]

    // MARK: - Verification
    func verifyEventDescriptionIsVisible(timeout: TimeInterval = UITestConstants.Timeouts.medium) {
        XCTAssertTrue(eventDescriptionText.waitForExistence(timeout: timeout), "Event detail description ('\(UITestConstants.AccessibilityID.eventDetailDescription)') not found.")
    }
} 
