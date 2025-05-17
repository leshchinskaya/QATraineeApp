import Foundation

// MARK: - Server Chat Message Structure

struct ServerChatMessage: Codable {
    let text: String
    let user: String
} 