//
//  ProfilePage.swift
//  QATraineeUITests
//
//  Created by Robotic Senior Software Engineer AI on INSERT_DATE_HERE.
//

import XCTest
import SharedAccessibilityIDs

class ProfilePage: BasePage {
    // MARK: - Elements
    private lazy var navigationBar = app.navigationBars[UITestConstants.NavigationBarTitles.profile]
    private lazy var loadingIndicator = app.otherElements[AccessibilityID.profileLoadingIndicator]
    private lazy var profileNameRow = app.otherElements[AccessibilityID.profileNameRow]

    // MARK: - Actions
    func waitForPageToLoad(timeout: TimeInterval = UITestConstants.Timeouts.short) {
        expectNavigationBar(with: UITestConstants.NavigationBarTitles.profile, timeout: timeout)
    }
    
    func waitForProfileDataToLoad(timeout: TimeInterval = UITestConstants.Timeouts.long) {
        if loadingIndicator.exists {
             XCTAssertTrue(loadingIndicator.waitForNonExistence(timeout: timeout), "Profile loading indicator did not disappear.")
        }
    }

    // MARK: - Verification
    func verifyProfileNameIsVisible(timeout: TimeInterval = UITestConstants.Timeouts.long) {
        XCTAssertTrue(profileNameRow.waitForExistence(timeout: timeout), "Profile name data ('\(AccessibilityID.profileNameRow)') not loaded/visible.")
    }
} 
