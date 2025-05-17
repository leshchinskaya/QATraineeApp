//
//  ChatPage.swift
//  QATraineeUITests
//
//  Created by Robotic Senior Software Engineer AI on INSERT_DATE_HERE.
//

import XCTest

class ChatPage: BasePage {
    // MARK: - Elements
    private lazy var navigationBar = app.navigationBars[UITestConstants.NavigationBarTitles.eventChat]
    private lazy var messageTextField = app.textFields[UITestConstants.AccessibilityID.chatMessageTextField]
    private lazy var sendMessageButton = app.buttons[UITestConstants.AccessibilityID.chatSendMessageButton]
    private lazy var messagesScrollView = app.scrollViews[UITestConstants.AccessibilityID.chatMessagesScrollView]

    // MARK: - Actions
    func waitForPageToLoad(timeout: TimeInterval = UITestConstants.Timeouts.short) {
        expectNavigationBar(with: UITestConstants.NavigationBarTitles.eventChat, timeout: timeout)
    }

    func typeMessage(_ message: String) {
        XCTAssertTrue(messageTextField.exists, "Message text field not found.")
        messageTextField.tap()
        messageTextField.typeText(message)
    }

    func tapSendMessageButton() {
        XCTAssertTrue(sendMessageButton.exists, "Send message button not found.")
        sendMessageButton.tap()
    }

    // MARK: - Verification
    func verifySendMessageButtonIsEnabled(_ isEnabled: Bool, message: String = "") {
        if isEnabled {
            XCTAssertTrue(sendMessageButton.isEnabled, "Send message button should be enabled. \(message)")
        } else {
            XCTAssertFalse(sendMessageButton.isEnabled, "Send message button should be disabled. \(message)")
        }
    }
    
    func verifyMessageInList(_ message: String, timeout: TimeInterval = UITestConstants.Timeouts.medium) {
        XCTAssertTrue(messagesScrollView.staticTexts[message].waitForExistence(timeout: timeout), "Sent message '\(message)' not found in chat.")
    }

    func verifyBotResponse(timeout: TimeInterval = UITestConstants.Timeouts.medium) {
        let botResponseMessage = messagesScrollView.staticTexts.containing(UITestConstants.Predicates.botResponseMessage).firstMatch
        XCTAssertTrue(botResponseMessage.waitForExistence(timeout: timeout), "Bot response not found in chat.")
    }
} 