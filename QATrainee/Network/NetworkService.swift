import Foundation

// Simulating a client-server interaction (REST-like)
class NetworkService {
    
    // Shared instance for easy access, though dependency injection is often preferred
    static let shared = NetworkService()
    private let session: URLSessionProtocol

    // Private init for singleton
    private init() {
        self.session = URLSession.shared
    }

    // Public init for testing and custom session
    init(session: URLSessionProtocol) {
        self.session = session
    }
    
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

    // MARK: - Generic Request Handler
    private func performRequest<T: Decodable>(url: URL?,
                                              urlDescription: String,
                                              completion: @escaping (Result<T, NetworkError>) -> Void) {
        guard let url = url else {
            print("[NetworkService] Invalid URL for \(urlDescription).")
            DispatchQueue.main.async {
                completion(.failure(.invalidURL("URL for \(urlDescription) was nil.")))
            }
            return
        }

        print("[NetworkService] Performing request to \(url.absoluteString) for \(urlDescription)...")

        session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("[NetworkService] Network request failed for \(urlDescription): \(error.localizedDescription)")
                    completion(.failure(.networkRequestFailed(error)))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("[NetworkService] Invalid response (not HTTPURLResponse) for \(urlDescription).")
                    completion(.failure(.invalidResponse(statusCode: -1))) // Using -1 for unknown status
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("[NetworkService] HTTP error for \(urlDescription): \(httpResponse.statusCode)")
                    completion(.failure(.invalidResponse(statusCode: httpResponse.statusCode)))
                    return
                }

                guard let jsonData = data else {
                    print("[NetworkService] No data received for \(urlDescription).")
                    completion(.failure(.noData))
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let decodedObject = try decoder.decode(T.self, from: jsonData)
                    print("[NetworkService] Successfully decoded \(urlDescription).")
                    completion(.success(decodedObject))
                } catch let decodingError {
                    print("[NetworkService] Error decoding \(urlDescription) JSON: \(decodingError.localizedDescription)")
                    completion(.failure(.decodingError(decodingError)))
                }
            }
        }.resume()
    }

    // MARK: - Event Endpoints
    func fetchEvents(completion: @escaping (Result<[Event], NetworkError>) -> Void) {
        let endpointPath = APIEnvironment.EndpointPath.events
        let url = endpointPath.getURL()
        
        performRequest(url: url, urlDescription: endpointPath.rawValue) { (result: Result<ServerEventsResponse, NetworkError>) in
            switch result {
            case .success(let serverResponse):
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
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Simulate creating an event
    // Bug: No proper error handling for creation failure (e.g., validation error from server, duplicate event)
    // Bug: Returns the created event immediately, but a real API might return a success/failure status first.
    func createEvent(name: String, date: Date, city: String, category: String, description: String, organizer: String, completion: @escaping (Result<Event, NetworkError>) -> Void) {
        
        let delayInSeconds = 1.5
        print("[NetworkService] Creating event '\(name)'... (simulated delay: \(delayInSeconds)s)")

        DispatchQueue.global().asyncAfter(deadline: .now() + delayInSeconds) {
            // Simulate a potential random failure (e.g. 5% chance for creation)
            if Double.random(in: 0..<1) < 0.05 {
                print("[NetworkService] Simulated network error while creating event '\(name)'.")
                let error: NetworkError = .simulatedError("Simulated server error creating event.")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            // Basic server-side validation simulation (though client-side is also buggily missing)
            if name.isEmpty || city.isEmpty {
                 print("[NetworkService] Server-side validation failed for event '\(name)': Name or City is empty.")
                let error: NetworkError = .validationError("Server validation: Event name and city cannot be empty.")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            let newEvent = Event(name: name, date: date, city: city, category: category.isEmpty ? "Other" : category, description: description, organizer: organizer)
            print("[NetworkService] Successfully created event '\(newEvent.name)'. (Note: Event list now reloads from server)")
            DispatchQueue.main.async {
                completion(.success(newEvent))
            }
        }
    }
    
    // Simulate registering for an event
    // Bug: No check if event exists or if user is already registered (server-side)
    func registerForEvent(eventId: UUID, userId: String, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        let delayInSeconds = 1.0
        print("[NetworkService] Registering user '\(userId)' for event ID '\(eventId)'... (simulated delay: \(delayInSeconds)s)")

        DispatchQueue.global().asyncAfter(deadline: .now() + delayInSeconds) {
            // Since self.events is removed, this logic can't find the event in the same way.
            // For now, we'll assume success if no random error, but the event won't be modified here directly.
            // This is a BUG: Registration status isn't truly persisted or checked against a server list.
            // A real implementation would send this to a server which would then update its data.
            
            // Simulate a small chance of registration failure
            if Double.random(in: 0..<1) < 0.03 {
                print("[NetworkService] Simulated registration failure for event ID '\(eventId)'.")
                let error: NetworkError = .simulatedError("Simulated error during event registration.")
                 DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            print("[NetworkService] User '\(userId)' registration attempt for event ID '\(eventId)' processed (simulated success, no actual data change here).")
            DispatchQueue.main.async {
                completion(.success(true))
            }
        }
    }

    // MARK: - User Profile Endpoint
    func fetchUserProfile(completion: @escaping (Result<UserProfile, NetworkError>) -> Void) {
        let endpointPath = APIEnvironment.EndpointPath.userProfile
        let url = endpointPath.getURL()
        performRequest(url: url, urlDescription: endpointPath.rawValue, completion: completion)
    }

    // MARK: - Cities Endpoint
    func fetchCities(completion: @escaping (Result<[City], NetworkError>) -> Void) {
        let endpointPath = APIEnvironment.EndpointPath.cities
        let url = endpointPath.getURL()
        
        performRequest(url: url, urlDescription: endpointPath.rawValue) { (result: Result<CitiesResponse, NetworkError>) in
            switch result {
            case .success(let citiesResponse):
                print("[NetworkService] Список городов успешно загружен и декодирован с URL.")
                completion(.success(citiesResponse.cities))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Chat Bot Message Endpoint
    func fetchBotMessageResponse(completion: @escaping (Result<ServerChatMessage, NetworkError>) -> Void) {
        let endpointPath = APIEnvironment.EndpointPath.message
        let url = endpointPath.getURL()
        performRequest(url: url, urlDescription: endpointPath.rawValue, completion: completion)
    }
}

// Note: For a GraphQL approach, we'd define mutations and queries.
// For REST, these functions map to different endpoints (e.g., GET /events, POST /events, POST /events/{id}/register).
// The "Non-working requests in Postman (bad documentation)" bug would be demonstrated by having this service
// behave slightly differently than what a hypothetical Postman collection/API doc might describe.
// E.g., required headers missing, wrong HTTP method, unexpected payload structure for errors. 
