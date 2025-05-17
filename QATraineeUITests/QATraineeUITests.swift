//
//  QATraineeUITests.swift
//  QATraineeUITests
//
//  Created by Maria Leshchinskaya on 14.05.2025.
//

import XCTest

final class QATraineeUITests: XCTestCase {
    var app: XCUIApplication!

    // Page Objects
    lazy var tabBarPage = TabBarPage(app: app)

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        // app.launchArguments += ["-UITesting"] // Optional: for conditional logic in app for UI tests
        app.launch()
        // tabBarPage is initialized lazily when first accessed, app will be non-nil by then.
    }

    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }

    @MainActor
    func testTabNavigation() throws {
        tabBarPage.verifyEventsTabIsPresent()
        let eventListPage = tabBarPage.tapEventsTab()
        eventListPage.waitForPageToLoad(timeout: UITestConstants.Timeouts.medium)

        tabBarPage.verifyCreateTabIsPresent()
        let createEventPage = tabBarPage.tapCreateTab()
        createEventPage.waitForPageToLoad(timeout: UITestConstants.Timeouts.short)

        tabBarPage.verifyChatTabIsPresent()
        let chatPage = tabBarPage.tapChatTab()
        chatPage.waitForPageToLoad(timeout: UITestConstants.Timeouts.short)

        tabBarPage.verifyProfileTabIsPresent()
        let profilePage = tabBarPage.tapProfileTab()
        profilePage.waitForPageToLoad(timeout: UITestConstants.Timeouts.medium)
    }

    @MainActor
    func testEventCreation_Success() throws {
        let createEventPage = tabBarPage.tapCreateTab()
        createEventPage.waitForPageToLoad(timeout: UITestConstants.Timeouts.short)

        let eventName = "UI Test Event \(Int.random(in: 100...999))"
        createEventPage.fillEventName(eventName)
        createEventPage.fillEventCity("UI Test City")
        createEventPage.fillEventDescription("This is a description from a UI test.")
        
        // Assuming fields being filled enables the button, no explicit check here,
        // but CreateEventPage.tapCreateButton() asserts it's enabled before tapping.
        createEventPage.tapCreateButton()

        createEventPage.verifySuccessAlertIsShown(timeout: UITestConstants.Timeouts.medium)
        createEventPage.dismissSuccessAlert()
    }
    
    @MainActor
    func testViewEventDetails() throws {
        let eventListPage = tabBarPage.tapEventsTab()
        eventListPage.waitForPageToLoad(timeout: UITestConstants.Timeouts.medium)
        eventListPage.waitForEventsToLoad(timeout: UITestConstants.Timeouts.long)

        let eventDetailPage = eventListPage.tapFirstEvent(timeout: UITestConstants.Timeouts.extraLong)
        eventDetailPage.verifyEventDescriptionIsVisible(timeout: UITestConstants.Timeouts.medium)
    }

    @MainActor
    func testProfileViewLoadsData() throws {
        let profilePage = tabBarPage.tapProfileTab()
        profilePage.waitForPageToLoad(timeout: UITestConstants.Timeouts.short)
        profilePage.waitForProfileDataToLoad(timeout: UITestConstants.Timeouts.long)
        profilePage.verifyProfileNameIsVisible(timeout: UITestConstants.Timeouts.long)
    }
    
    @MainActor
    func testChatSendMessage() throws {
        let chatPage = tabBarPage.tapChatTab()
        chatPage.waitForPageToLoad(timeout: UITestConstants.Timeouts.short)

        // Initial state check
        chatPage.verifySendMessageButtonIsEnabled(false, message: "Button should be disabled when text field is empty")

        let testMessage = "Hello from UI Test! \(Date())"
        chatPage.typeMessage(testMessage)
        
        chatPage.verifySendMessageButtonIsEnabled(true, message: "Button should be enabled after typing text")
        chatPage.tapSendMessageButton()
        
        chatPage.verifyMessageInList(testMessage, timeout: UITestConstants.Timeouts.medium)
        chatPage.verifyBotResponse(timeout: UITestConstants.Timeouts.medium)
    }
}

extension XCUIElement {
    func waitForNonExistence(timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
}
