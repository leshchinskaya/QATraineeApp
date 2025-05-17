//
//  TabBarPage.swift
//  QATraineeUITests
//
//  Created by Robotic Senior Software Engineer AI on INSERT_DATE_HERE.
//

import XCTest

class TabBarPage: BasePage {
    // MARK: - Elements
    private lazy var eventsTab = app.tabBars.buttons[UITestConstants.TabBar.events]
    private lazy var createTab = app.tabBars.buttons[UITestConstants.TabBar.create]
    private lazy var chatTab = app.tabBars.buttons[UITestConstants.TabBar.chat]
    private lazy var profileTab = app.tabBars.buttons[UITestConstants.TabBar.profile]

    // MARK: - Actions
    @discardableResult
    func tapEventsTab() -> EventListPage {
        XCTAssertTrue(eventsTab.exists, "\(UITestConstants.TabBar.events) tab not found.")
        eventsTab.tap()
        return EventListPage(app: app)
    }

    @discardableResult
    func tapCreateTab() -> CreateEventPage {
        XCTAssertTrue(createTab.exists, "\(UITestConstants.TabBar.create) tab not found.")
        createTab.tap()
        return CreateEventPage(app: app)
    }

    @discardableResult
    func tapChatTab() -> ChatPage {
        XCTAssertTrue(chatTab.exists, "\(UITestConstants.TabBar.chat) tab not found.")
        chatTab.tap()
        return ChatPage(app: app)
    }

    @discardableResult
    func tapProfileTab() -> ProfilePage {
        XCTAssertTrue(profileTab.exists, "\(UITestConstants.TabBar.profile) tab not found.")
        profileTab.tap()
        return ProfilePage(app: app)
    }
    
    // MARK: - Verification
    func verifyEventsTabIsPresent() { XCTAssertTrue(eventsTab.exists, "\(UITestConstants.TabBar.events) tab not found.") }
    func verifyCreateTabIsPresent() { XCTAssertTrue(createTab.exists, "\(UITestConstants.TabBar.create) tab not found.") }
    func verifyChatTabIsPresent() { XCTAssertTrue(chatTab.exists, "\(UITestConstants.TabBar.chat) tab not found.") }
    func verifyProfileTabIsPresent() { XCTAssertTrue(profileTab.exists, "\(UITestConstants.TabBar.profile) tab not found.") }
} 