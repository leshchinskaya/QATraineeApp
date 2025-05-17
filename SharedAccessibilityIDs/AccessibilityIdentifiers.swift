import Foundation // For UUID

public enum AccessibilityID {
    // ContentView
    public static let eventListTabLabel = "eventListTabLabel"
    public static let createEventTabLabel = "createEventTabLabel"
    public static let chatTabLabel = "chatTabLabel"
    public static let profileTabLabel = "profileTabLabel"
    public static let mainTabView = "mainTabView"

    // ChatView
    public static func chatMessage(id: UUID) -> String { "chatMessage_\(id.uuidString)" }
    public static let chatMessagesScrollView = "chatMessagesScrollView"
    public static let chatMessageTextField = "chatMessageTextField"
    public static let chatSendMessageButton = "chatSendMessageButton"

    // CreateEventView
    public static let createEventNameField = "createEventNameField"
    public static let createEventDateField = "createEventDateField"
    public static let createEventCityField = "createEventCityField"
    public static let createEventCategoryPicker = "createEventCategoryPicker"
    public static let createEventOrganizerField = "createEventOrganizerField"
    public static let createEventDescriptionField = "createEventDescriptionField"
    public static let createEventSubmitButton = "createEventSubmitButton"

    // EventDetailView
    public static func eventDetailTitle(eventName: String) -> String { "eventDetailTitle_\(eventName)" }
    public static func eventDetailOrganizer(organizerName: String) -> String { "eventDetailOrganizer_\(organizerName)" }
    public static let eventDetailDate = "eventDetailDate"
    public static func eventDetailCity(cityName: String) -> String { "eventDetailCity_\(cityName)" }
    public static func eventDetailCategory(categoryName: String) -> String { "eventDetailCategory_\(categoryName)" }
    public static let eventDetailDescription = "eventDetailDescription"
    public static let eventDetailAttendeesCount = "eventDetailAttendeesCount"
    public static func registerButton(eventName: String) -> String { "registerButton_\(eventName)" }
    public static let eventDetailMainVStack = "eventDetailMainVStack"
    public static func chatButton(eventName: String) -> String { "chatButton_\(eventName)" }

    // EventFilterView
    public static let filterCategoryPicker = "filterCategoryPicker"
    public static let filterStartDatePicker = "filterStartDatePicker"
    public static let filterEndDatePicker = "filterEndDatePicker"
    public static let filterCityPicker = "filterCityPicker"
    public static let filterApplyButton = "filterApplyButton"
    public static let filterResetButton = "filterResetButton"
    public static let filterDoneButton = "filterDoneButton"

    // EventListView
    public static let eventListLoadingIndicator = "eventListLoadingIndicator"
    public static let showFiltersButton = "showFiltersButton"
    public static let eventRowPrefix = "eventRow_" // For UI Test predicate
    public static func eventRow(eventId: UUID) -> String { "\(eventRowPrefix)\(eventId.uuidString)" }

    // ProfileView
    public static let profileLoadingIndicator = "profileLoadingIndicator"
    public static let profileErrorMessageText = "profileErrorMessageText"
    public static let profileForm = "profileForm"
    public static let profileNotLoadedText = "profileNotLoadedText"
    public static let refreshProfileButton = "refreshProfileButton"
    
    // Helper for ProfileRow, matching the logic in ProfileView
    private static func sanitizeForIdentifier(_ input: String) -> String {
        input.filter { !$0.isWhitespace && ($0.isLetter || $0.isNumber) }
    }
    public static func profileRow(label: String) -> String { "profileRow_\(sanitizeForIdentifier(label))" }
    
    // Specific instance used in UI tests, derived from the general function
    // This matches the old UITestConstants.AccessibilityID.profileNameRow value
    public static let profileNameRow = profileRow(label: "Имя")
} 