//
//  CreateEventPage.swift
//  QATraineeUITests
//
//  Created by Robotic Senior Software Engineer AI on INSERT_DATE_HERE.
//

import XCTest
import SharedAccessibilityIDs

class CreateEventPage: BasePage {
    // MARK: - Elements
    private lazy var navigationBar = app.navigationBars[UITestConstants.NavigationBarTitles.newEvent]
    private lazy var eventNameField = app.textFields[AccessibilityID.createEventNameField]
    private lazy var eventCityField = app.textFields[AccessibilityID.createEventCityField]
    private lazy var eventDescriptionField = app.textFields[AccessibilityID.createEventDescriptionField]
    private lazy var createButton = app.buttons[AccessibilityID.createEventSubmitButton]
    private lazy var successAlert = app.alerts[UITestConstants.Alerts.successTitle]
    private lazy var successAlertOKButton = successAlert.buttons[UITestConstants.Alerts.okButton]

    // MARK: - Actions
    func waitForPageToLoad(timeout: TimeInterval = UITestConstants.Timeouts.short) {
         expectNavigationBar(with: UITestConstants.NavigationBarTitles.newEvent, timeout: timeout)
    }
    
    func fillEventName(_ name: String) {
        eventNameField.tap()
        eventNameField.typeText(name + "\n")
    }

    func fillEventCity(_ city: String) {
        eventCityField.tap()
        eventCityField.typeText(city + "\n")
    }

    func fillEventDescription(_ description: String) {
        eventDescriptionField.tap()
        eventDescriptionField.typeText(description + "\n")
    }

    func tapCreateButton() {
        XCTAssertTrue(createButton.isEnabled, "Create button should be enabled before tapping.")
        createButton.tap()
    }

    func dismissSuccessAlert() {
        XCTAssertTrue(successAlertOKButton.waitForExistence(timeout: UITestConstants.Timeouts.medium), "'\(UITestConstants.Alerts.okButton)' button on success alert not found.")
        successAlertOKButton.tap()
    }

    // MARK: - Verification
    func verifySuccessAlertIsShown(timeout: TimeInterval = UITestConstants.Timeouts.medium) {
        XCTAssertTrue(successAlert.waitForExistence(timeout: timeout), "'\(UITestConstants.Alerts.successTitle)' alert did not appear.")
    }
} 
