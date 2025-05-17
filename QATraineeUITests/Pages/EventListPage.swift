//
//  EventListPage.swift
//  QATraineeUITests
//
//  Created by Robotic Senior Software Engineer AI on INSERT_DATE_HERE.
//

import XCTest

class EventListPage: BasePage {
    // MARK: - Elements
    private lazy var navigationBar = app.navigationBars[UITestConstants.NavigationBarTitles.eventList]
    private lazy var loadingIndicator = app.otherElements[UITestConstants.AccessibilityID.eventListLoadingIndicator]
    private lazy var eventRowQuery = app.buttons.matching(UITestConstants.Predicates.eventRow)
    
    var firstEventCell: XCUIElement {
        return eventRowQuery.element(boundBy: 0)
    }

    // MARK: - Actions
    func waitForPageToLoad(timeout: TimeInterval = UITestConstants.Timeouts.medium) {
        expectNavigationBar(with: UITestConstants.NavigationBarTitles.eventList, timeout: timeout)
    }
    
    func waitForEventsToLoad(timeout: TimeInterval = UITestConstants.Timeouts.long) {
        if loadingIndicator.exists {
            XCTAssertTrue(loadingIndicator.waitForNonExistence(timeout: timeout), "Event list loading indicator did not disappear.")
        }
    }

    @discardableResult
    func tapFirstEvent(timeout: TimeInterval = UITestConstants.Timeouts.extraLong) -> EventDetailPage {
        XCTAssertTrue(firstEventCell.waitForExistence(timeout: timeout), "Event cells not found.")
        firstEventCell.tap()
        return EventDetailPage(app: app)
    }
} 