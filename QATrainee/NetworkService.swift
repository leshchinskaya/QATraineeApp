import Foundation

// Simulating a client-server interaction (REST-like)
class NetworkService {
    
    // Shared instance for easy access, though dependency injection is often preferred
    static let shared = NetworkService()
    private init() {}
    
    // The local sampleEvents array will be removed as events are fetched from the server.
    // private var events: [Event] = sampleEvents 

    // MARK: - Server Event Structures
    // Definitions are now in EventModels.swift
    
    // Date formatter for parsing server date strings
    private let serverDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy 'в' HH:mm"
        formatter.locale = Locale(identifier: "ru_RU") // Assuming Russian locale for parsing
        formatter.timeZone = TimeZone.current // Or a specific timezone if known
        return formatter
    }()

    func fetchEvents(completion: @escaping (Result<[Event], Error>) -> Void) {
        print("[NetworkService] Fetching events from server...")
        
        guard let url = URL(string: "https://r2.mocker.surfstudio.ru/qa_trainee/events") else {
            print("[NetworkService] Invalid URL for fetching events.")
            let error = NSError(domain: "NetworkServiceError", code: -30, userInfo: [NSLocalizedDescriptionKey: "Неверный URL для списка событий."])
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("[NetworkService] Error fetching events: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                    print("[NetworkService] Invalid HTTP response or status code for events: \(statusCode)")
                    let statusError = NSError(domain: "NetworkServiceError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Ошибка сервера при загрузке событий (статус: \(statusCode))."])
                    completion(.failure(statusError))
                    return
                }
                
                guard let jsonData = data else {
                    print("[NetworkService] No data received for events.")
                    let dataError = NSError(domain: "NetworkServiceError", code: -32, userInfo: [NSLocalizedDescriptionKey: "Данные событий не были получены от сервера."])
                    completion(.failure(dataError))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let serverResponse = try decoder.decode(ServerEventsResponse.self, from: jsonData)
                    
                    // Map ServerEvent to Event
                    let mappedEvents: [Event] = serverResponse.events.compactMap { serverEvent in
                        guard let eventDate = self.serverDateFormatter.date(from: serverEvent.date) else {
                            print("[NetworkService] Failed to parse date string: \(serverEvent.date) for event \(serverEvent.name)")
                            return nil // Skip this event if date parsing fails
                        }
                        // Create a new UUID for each event, or use a deterministic one if needed
                        return Event(
                            id: UUID(), // Generate new UUID
                            name: serverEvent.name,
                            date: eventDate,
                            city: serverEvent.city,
                            // Provide default values for fields not in server response
                            category: "Общее", // Default category
                            description: "Описание будет доступно позже.", // Default description
                            isRegistered: false, organizer: "Организатор уточняется", // Default registration status
                            attendees: [] // Default attendees
                        )
                    }
                    
                    print("[NetworkService] Successfully fetched and mapped \(mappedEvents.count) events.")
                    completion(.success(mappedEvents))
                    
                } catch {
                    print("[NetworkService] Error decoding events JSON: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    // Simulate creating an event
    // Bug: No proper error handling for creation failure (e.g., validation error from server, duplicate event)
    // Bug: Returns the created event immediately, but a real API might return a success/failure status first.
    func createEvent(name: String, date: Date, city: String, category: String, description: String, organizer: String, completion: @escaping (Result<Event, Error>) -> Void) {
        
        let delayInSeconds = 1.5
        print("[NetworkService] Creating event '\(name)'... (simulated delay: \(delayInSeconds)s)")

        DispatchQueue.global().asyncAfter(deadline: .now() + delayInSeconds) {
            // Simulate a potential random failure (e.g. 5% chance for creation)
            if Double.random(in: 0..<1) < 0.05 {
                print("[NetworkService] Simulated network error while creating event '\(name)'.")
                let error = NSError(domain: "NetworkError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Simulated server error creating event."])
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            // Basic server-side validation simulation (though client-side is also buggily missing)
            if name.isEmpty || city.isEmpty {
                 print("[NetworkService] Server-side validation failed for event '\(name)': Name or City is empty.")
                let error = NSError(domain: "ValidationError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Server validation: Event name and city cannot be empty."])
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            let newEvent = Event(name: name, date: date, city: city, category: category.isEmpty ? "Other" : category, description: description, organizer: organizer)
            // self.events.append(newEvent) // Commented out as self.events is no longer the source of truth
            // print("[NetworkService] Successfully created event '\(newEvent.name)'. Total events: \(self.events.count)") // Commented out
            print("[NetworkService] Successfully created event '\(newEvent.name)'. (Note: Event list now reloads from server)")
            DispatchQueue.main.async {
                completion(.success(newEvent))
            }
        }
    }
    
    // Simulate registering for an event
    // Bug: No check if event exists or if user is already registered (server-side)
    func registerForEvent(eventId: UUID, userId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let delayInSeconds = 1.0
        print("[NetworkService] Registering user '\(userId)' for event ID '\(eventId)'... (simulated delay: \(delayInSeconds)s)")

        DispatchQueue.global().asyncAfter(deadline: .now() + delayInSeconds) {
            // Since self.events is removed, this logic can't find the event in the same way.
            // For now, we'll assume success if no random error, but the event won't be modified here directly.
            // This is a BUG: Registration status isn't truly persisted or checked against a server list.
            // A real implementation would send this to a server which would then update its data.
            
            // if let index = self.events.firstIndex(where: { $0.id == eventId }) { // Commented out
                // Simulate a small chance of registration failure
                if Double.random(in: 0..<1) < 0.03 {
                    print("[NetworkService] Simulated registration failure for event ID '\(eventId)'.")
                    let error = NSError(domain: "RegistrationError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Simulated error during event registration."])
                     DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                
                // // For simplicity, we don't check if already registered here on the "server"
                // // The client-side already updates this, this is just a confirmation.
                // if !self.events[index].attendees.contains(userId) { // Commented out
                //      self.events[index].attendees.append(userId) // Commented out
                // }
                // self.events[index].isRegistered = true // Server might also track this // Commented out
                // print("[NetworkService] User '\(userId)' successfully registered for event '\(self.events[index].name)'.") // Commented out
                print("[NetworkService] User '\(userId)' registration attempt for event ID '\(eventId)' processed (simulated success, no actual data change here).")
                DispatchQueue.main.async {
                    completion(.success(true))
                }
            // } else { // Commented out
            //     print("[NetworkService] Event ID '\(eventId)' not found for registration (original local check removed).") // Commented out
            //     let error = NSError(domain: "NotFoundError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Event not found for registration (original local check removed)."])
            //     DispatchQueue.main.async {
            //         completion(.failure(error))
            //     }
            // }
        }
    }

    // MARK: - User Profile

    func fetchUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        print("NetworkService: Инициация загрузки профиля пользователя с URL...")
        
        guard let url = URL(string: "https://r2.mocker.surfstudio.ru/qq_trainee/user/profile") else {
            print("NetworkService: Неверный URL для профиля пользователя.")
            let error = NSError(domain: "NetworkServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Неверный URL для профиля пользователя."])
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Возвращаемся в главный поток для обновления UI
            DispatchQueue.main.async {
                if let error = error {
                    print("NetworkService: Ошибка при запросе профиля пользователя: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("NetworkService: Неверный HTTP ответ или статус код.")
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                    let statusError = NSError(domain: "NetworkServiceError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Ошибка сервера при загрузке профиля (статус: \(statusCode))."])
                    completion(.failure(statusError))
                    return
                }
                
                guard let jsonData = data else {
                    print("NetworkService: Данные профиля пользователя не получены.")
                    let dataError = NSError(domain: "NetworkServiceError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Данные профиля пользователя не были получены от сервера."])
                    completion(.failure(dataError))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let userProfile = try decoder.decode(UserProfile.self, from: jsonData)
                    print("NetworkService: Профиль пользователя успешно загружен и декодирован с URL.")
                    completion(.success(userProfile))
                } catch {
                    print("NetworkService: Ошибка декодирования JSON профиля пользователя с URL: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }.resume() // Не забудьте запустить задачу!
    }

    // MARK: - Cities

    func fetchCities(completion: @escaping (Result<[City], Error>) -> Void) {
        print("NetworkService: Инициация загрузки списка городов с URL...")

        guard let url = URL(string: "https://r2.mocker.surfstudio.ru/qq_trainee/cities") else {
            print("NetworkService: Неверный URL для списка городов.")
            let error = NSError(domain: "NetworkServiceError", code: -10, userInfo: [NSLocalizedDescriptionKey: "Неверный URL для списка городов."])
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("NetworkService: Ошибка при запросе списка городов: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("NetworkService: Неверный HTTP ответ или статус код при запросе городов.")
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                    let statusError = NSError(domain: "NetworkServiceError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Ошибка сервера при загрузке городов (статус: \(statusCode))."])
                    completion(.failure(statusError))
                    return
                }

                guard let jsonData = data else {
                    print("NetworkService: Данные списка городов не получены.")
                    let dataError = NSError(domain: "NetworkServiceError", code: -12, userInfo: [NSLocalizedDescriptionKey: "Данные списка городов не были получены от сервера."])
                    completion(.failure(dataError))
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let citiesResponse = try decoder.decode(CitiesResponse.self, from: jsonData)
                    print("NetworkService: Список городов успешно загружен и декодирован с URL.")
                    completion(.success(citiesResponse.cities))
                } catch {
                    print("NetworkService: Ошибка декодирования JSON списка городов с URL: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // MARK: - Chat Bot Message

    struct ServerChatMessage: Codable {
        let text: String
        let user: String
    }

    func fetchBotMessageResponse(completion: @escaping (Result<ServerChatMessage, Error>) -> Void) {
        print("NetworkService: Инициация загрузки ответного сообщения от бота...")

        guard let url = URL(string: "https://r2.mocker.surfstudio.ru/qa_trainee/message") else {
            print("NetworkService: Неверный URL для ответного сообщения.")
            let error = NSError(domain: "NetworkServiceError", code: -20, userInfo: [NSLocalizedDescriptionKey: "Неверный URL для ответного сообщения от бота."])
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("NetworkService: Ошибка при запросе ответного сообщения: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("NetworkService: Неверный HTTP ответ или статус код при запросе ответного сообщения.")
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                    let statusError = NSError(domain: "NetworkServiceError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Ошибка сервера при загрузке ответного сообщения (статус: \(statusCode))."])
                    completion(.failure(statusError))
                    return
                }

                guard let jsonData = data else {
                    print("NetworkService: Данные ответного сообщения не получены.")
                    let dataError = NSError(domain: "NetworkServiceError", code: -22, userInfo: [NSLocalizedDescriptionKey: "Данные ответного сообщения не были получены от сервера."])
                    completion(.failure(dataError))
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let botMessage = try decoder.decode(ServerChatMessage.self, from: jsonData)
                    print("NetworkService: Ответное сообщение успешно загружено: '\(botMessage.text)' от пользователя '\(botMessage.user)'.")
                    completion(.success(botMessage))
                } catch {
                    print("NetworkService: Ошибка декодирования JSON ответного сообщения: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // MARK: - Helper for Simulating Errors
}

// Note: For a GraphQL approach, we'd define mutations and queries.
// For REST, these functions map to different endpoints (e.g., GET /events, POST /events, POST /events/{id}/register).
// The "Non-working requests in Postman (bad documentation)" bug would be demonstrated by having this service
// behave slightly differently than what a hypothetical Postman collection/API doc might describe.
// E.g., required headers missing, wrong HTTP method, unexpected payload structure for errors. 
