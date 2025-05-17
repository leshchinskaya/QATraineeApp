import Foundation

enum APIEnvironment {
    static let baseURLString = "https://r2.mocker.surfstudio.ru/qa_trainee"

    enum EndpointPath: String, CustomStringConvertible {
        case events = "/events"
        case userProfile = "/user/profile"
        case cities = "/cities"
        case message = "/message"

        var description: String {
            return self.rawValue
        }

        func getURL() -> URL? {
            let urlString = APIEnvironment.baseURLString + self.rawValue
            return URL(string: urlString)
        }
    }
} 