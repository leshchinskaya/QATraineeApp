import Foundation

// UserProfile data structure
struct UserProfile: Codable, Identifiable {
    let id: String
    let firstName: String?
    let lastName: String?
    let email: String?
    let phone: String?
    let birthday: String? // Store as String, format in View if needed
    let sex: String?

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case phone
        case birthday
        case sex
    }

    // Computed property for display
    var displayName: String {
        let fn = firstName ?? ""
        let ln = lastName ?? ""
        if fn.isEmpty && ln.isEmpty {
            return "Имя не указано"
        }
        return "\(fn) \(ln)".trimmingCharacters(in: .whitespaces)
    }

    var displaySex: String {
        switch sex?.lowercased() {
        case "male": return "Мужской"
        case "female": return "Женский"
        default: return "Не указан"
        }
    }
    
    var displayBirthday: String {
        if let birthdayDateStr = birthday {
            // Basic reformatting if it's in "YYYY-MM-DD"
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy-MM-dd"
            if let dateObj = inputFormatter.date(from: birthdayDateStr) {
                let outputFormatter = DateFormatter()
                outputFormatter.dateStyle = .long
                outputFormatter.locale = Locale(identifier: "ru_RU")
                return outputFormatter.string(from: dateObj)
            }
            return birthdayDateStr // Fallback to original string if parsing fails
        }
        return "Не указана"
    }
} 