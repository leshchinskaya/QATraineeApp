import Foundation

enum NetworkError: Error, LocalizedError, Equatable {
    case invalidURL(String)
    case networkRequestFailed(Error) // Wraps the underlying URLSession error
    case invalidResponse(statusCode: Int)
    case noData
    case decodingError(Error) // Wraps the underlying DecodingError
    case serverError(statusCode: Int, message: String? = nil)
    case simulatedError(String)
    case validationError(String)

    public var errorDescription: String? {
        switch self {
        case .invalidURL(let context): return "Неверный URL: \(context)."
        case .networkRequestFailed(let error): return "Ошибка сетевого запроса: \(error.localizedDescription)."
        case .invalidResponse(let statusCode): return "Неверный ответ от сервера (статус: \(statusCode))."
        case .noData: return "Данные не были получены от сервера."
        case .decodingError(let error): return "Ошибка декодирования данных: \(error.localizedDescription)."
        case .serverError(let statusCode, let message):
            return "Ошибка сервера (статус: \(statusCode))" + (message.map { ": \($0)" } ?? ".")
        case .simulatedError(let message): return "Симулированная ошибка: \(message)."
        case .validationError(let message): return "Ошибка валидации: \(message)."
        }
    }

    // Equatable conformance, simplified for testing purposes
    // Note: Comparing associated Error values directly can be complex.
    // For robust Equatable conformance, you might need to compare specific properties of the errors.
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        return lhs.localizedDescription == rhs.localizedDescription // Simplified comparison
    }
} 