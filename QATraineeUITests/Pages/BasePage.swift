//
//  BasePage.swift
//  QATraineeUITests
//
//  Created by Robotic Senior Software Engineer AI on INSERT_DATE_HERE.
//

import XCTest

class BasePage {
    let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    func expectNavigationBar(with title: String, timeout: TimeInterval = UITestConstants.Timeouts.medium) {
        XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: timeout), "Navigation bar with title '\(title)' not found.")
    }
} 