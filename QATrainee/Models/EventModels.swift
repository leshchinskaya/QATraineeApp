import SwiftUI // For Identifiable, Date, UUID

// MARK: - Core Event Model (used throughout the UI)

struct Event: Identifiable, Codable {
    var id = UUID()
    var name: String
    var date: Date
    var city: String
    var category: String // e.g., "Music", "Sports", "Conference"
    var description: String
    var isRegistered: Bool = false // To track user registration status
    var organizer: String // Could be a User ID or name
    var attendees: [String] = [] // List of attendee User IDs or names
}

// MARK: - Server Event Structures (for decoding server responses)

struct ServerEvent: Codable {
    let id: String // Server ID, e.g., "event1"
    let name: String
    let date: String // Date as string, e.g., "13/06/2025 в 09:00"
    let city: String
}

struct ServerEventsResponse: Codable {
    let events: [ServerEvent]
} 