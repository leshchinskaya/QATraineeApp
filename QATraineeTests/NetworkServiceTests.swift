import XCTest
@testable import QATrainee

class NetworkServiceTests: XCTestCase {

    var sut: NetworkService!
    var mockSession: MockURLSession!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockSession = MockURLSession()
        sut = NetworkService(session: mockSession) // Initialize with mock session
    }

    override func tearDownWithError() throws {
        sut = nil
        mockSession = nil
        try super.tearDownWithError()
    }

    // Test cases will go here

    func testFetchEvents_Success() throws {
        let expectation = self.expectation(description: "FetchEvents success expectation")
        
        // 1. Prepare mock data
        let mockServerEvents = [
            ServerEvent(id: "event1", name: "Конференция Разработчиков", date: "15/07/2025 в 10:00", city: "Москва"),
            ServerEvent(id: "event2", name: "Семинар по QA", date: "20/08/2025 в 14:30", city: "Санкт-Петербург")
        ]
        let mockServerResponse = ServerEventsResponse(events: mockServerEvents)
        let mockJsonData = try JSONEncoder().encode(mockServerResponse)
        
        // 2. Configure mock session
        let expectedURL = APIEnvironment.EndpointPath.events.getURL()!
        mockSession.nextData = mockJsonData
        mockSession.nextResponse = HTTPURLResponse(url: expectedURL,
                                                 statusCode: 200,
                                                 httpVersion: nil,
                                                 headerFields: nil)
        
        var actualEvents: [Event]?
        var actualError: Error?
        
        // 3. Call the method
        sut.fetchEvents { result in
            switch result {
            case .success(let events):
                actualEvents = events
            case .failure(let error):
                actualError = error
            }
            expectation.fulfill()
        }
        
        // 4. Wait for expectation
        waitForExpectations(timeout: 1.0)
        
        // 5. Assert URL
        XCTAssertEqual(mockSession.lastURL, expectedURL)
        
        // 6. Assert resume was called
        XCTAssertTrue(mockSession.nextDataTask.resumeWasCalled)
        
        // 7. Assert result
        XCTAssertNotNil(actualEvents)
        XCTAssertNil(actualError)
        XCTAssertEqual(actualEvents?.count, 2, "Should have mapped 2 events.")
        guard let firstEvent = actualEvents?.first else {
            XCTFail("First event is nil")
            return
        }
        XCTAssertEqual(actualEvents?.first?.name, "Конференция Разработчиков")
        XCTAssertEqual(actualEvents?.first?.city, "Москва")
        // We should also check the date parsing, but it requires a specific date object. For now, checking name and city.
        // The Event struct generates a new UUID, so we can't easily check ID against mockServerEvents.id
    }

    func testFetchEvents_Failure_NetworkError() {
        let expectation = self.expectation(description: "FetchEvents network error expectation")
        
        // 1. Configure mock session for network error
        let expectedError = NSError(domain: "NSURLErrorDomain", code: NSURLErrorNotConnectedToInternet, userInfo: nil)
        let expectedURL = APIEnvironment.EndpointPath.events.getURL()!
        mockSession.nextError = expectedError
        mockSession.nextResponse = HTTPURLResponse(url: expectedURL,
                                                 statusCode: 200, // Status code doesn't matter if there's a primary error
                                                 httpVersion: nil,
                                                 headerFields: nil)
        
        var actualEvents: [Event]?
        var actualError: Error?
        
        // 2. Call the method
        sut.fetchEvents { result in
            switch result {
            case .success(let events):
                actualEvents = events
            case .failure(let error):
                actualError = error
            }
            expectation.fulfill()
        }
        
        // 3. Wait for expectation
        waitForExpectations(timeout: 1.0)
        
        // 4. Assert URL
        XCTAssertEqual(mockSession.lastURL, expectedURL)
        
        // 5. Assert resume was called
        XCTAssertTrue(mockSession.nextDataTask.resumeWasCalled)
        
        // 6. Assert result
        XCTAssertNil(actualEvents)
        XCTAssertNotNil(actualError)
        guard let networkErr = actualError as? NetworkError else {
            XCTFail("Error was not a NetworkError: \(String(describing: actualError))")
            return
        }
        XCTAssertEqual(networkErr, NetworkError.networkRequestFailed(expectedError),
                       "Expected .networkRequestFailed(\(expectedError.localizedDescription)), got \(networkErr.localizedDescription)")
    }

    func testFetchEvents_Failure_HTTPError() {
        let expectation = self.expectation(description: "FetchEvents HTTP error expectation")
        
        // 1. Configure mock session for HTTP error
        let httpErrorStatusCode = 500
        let expectedURL = APIEnvironment.EndpointPath.events.getURL()!
        mockSession.nextResponse = HTTPURLResponse(url: expectedURL,
                                                 statusCode: httpErrorStatusCode,
                                                 httpVersion: nil,
                                                 headerFields: nil)
        // No data is needed as the status code check comes first
        
        var actualEvents: [Event]?
        var actualError: Error?
        
        // 2. Call the method
        sut.fetchEvents { result in
            switch result {
            case .success(let events):
                actualEvents = events
            case .failure(let error):
                actualError = error
            }
            expectation.fulfill()
        }
        
        // 3. Wait for expectation
        waitForExpectations(timeout: 1.0)
        
        // 4. Assert URL
        XCTAssertEqual(mockSession.lastURL, expectedURL)
        
        // 5. Assert resume was called
        XCTAssertTrue(mockSession.nextDataTask.resumeWasCalled)
        
        // 6. Assert result
        XCTAssertNil(actualEvents)
        XCTAssertNotNil(actualError)
        guard let networkErr = actualError as? NetworkError else {
            XCTFail("Error was not a NetworkError: \(String(describing: actualError))")
            return
        }
        XCTAssertEqual(networkErr, NetworkError.invalidResponse(statusCode: httpErrorStatusCode),
                       "Expected .invalidResponse with status \(httpErrorStatusCode), got \(networkErr.localizedDescription)")
    }

    func testFetchEvents_Failure_NoData() {
        let expectation = self.expectation(description: "FetchEvents no data expectation")
        
        // 1. Configure mock session for no data
        let expectedURL = APIEnvironment.EndpointPath.events.getURL()!
        mockSession.nextData = nil // Explicitly set to nil
        mockSession.nextResponse = HTTPURLResponse(url: expectedURL,
                                                 statusCode: 200, // Successful status code
                                                 httpVersion: nil,
                                                 headerFields: nil)
        
        var actualEvents: [Event]?
        var actualError: Error?
        
        // 2. Call the method
        sut.fetchEvents { result in
            switch result {
            case .success(let events):
                actualEvents = events
            case .failure(let error):
                actualError = error
            }
            expectation.fulfill()
        }
        
        // 3. Wait for expectation
        waitForExpectations(timeout: 1.0)
        
        // 4. Assert URL
        XCTAssertEqual(mockSession.lastURL, expectedURL)
        
        // 5. Assert resume was called
        XCTAssertTrue(mockSession.nextDataTask.resumeWasCalled)
        
        // 6. Assert result
        XCTAssertNil(actualEvents)
        XCTAssertNotNil(actualError)
        guard let networkErr = actualError as? NetworkError else {
            XCTFail("Error was not a NetworkError: \(String(describing: actualError))")
            return
        }
        XCTAssertEqual(networkErr, NetworkError.noData,
                       "Expected .noData, got \(networkErr.localizedDescription)")
    }

    func testFetchEvents_Failure_DecodingError() throws {
        let expectation = self.expectation(description: "FetchEvents decoding error expectation")
        
        // 1. Prepare malformed mock data
        let malformedJsonString = "{\"events\": [{\"id\": \"event1\", \"name\": \"Malformed Event\"}]}" // Malformed: e.g. server event might expect more fields
        let mockJsonData = Data(malformedJsonString.utf8)
        
        // 2. Configure mock session
        let expectedURL = APIEnvironment.EndpointPath.events.getURL()!
        mockSession.nextData = mockJsonData
        mockSession.nextResponse = HTTPURLResponse(url: expectedURL,
                                                 statusCode: 200,
                                                 httpVersion: nil,
                                                 headerFields: nil)
        
        var actualEvents: [Event]?
        var actualError: Error?
        
        // 3. Call the method
        sut.fetchEvents { result in
            switch result {
            case .success(let events):
                actualEvents = events
            case .failure(let error):
                actualError = error
            }
            expectation.fulfill()
        }
        
        // 4. Wait for expectation
        waitForExpectations(timeout: 1.0)
        
        // 5. Assert URL
        XCTAssertEqual(mockSession.lastURL, expectedURL)
        
        // 6. Assert resume was called
        XCTAssertTrue(mockSession.nextDataTask.resumeWasCalled)
        
        // 7. Assert result
        XCTAssertNil(actualEvents)
        XCTAssertNotNil(actualError)
        guard let networkErr = actualError as? NetworkError else {
            XCTFail("Error was not a NetworkError: \(String(describing: actualError))")
            return
        }
        guard case .decodingError = networkErr else { XCTFail("Expected .decodingError, got \(networkErr)"); return }
    }

    // MARK: - User Profile Tests

    func testFetchUserProfile_Success() throws {
        let expectation = self.expectation(description: "FetchUserProfile success expectation")

        // 1. Prepare mock data
        let mockUserProfile = UserProfile(id: "user123", 
                                        firstName: "Мария", 
                                        lastName: "Тестова", 
                                        email: "maria.test@example.com", 
                                        phone: "+79001234567", 
                                        birthday: "1990-05-15", 
                                        sex: "female")
        let mockJsonData = try JSONEncoder().encode(mockUserProfile)

        // 2. Configure mock session
        let expectedURL = APIEnvironment.EndpointPath.userProfile.getURL()!
        mockSession.nextData = mockJsonData
        mockSession.nextResponse = HTTPURLResponse(url: expectedURL,
                                                 statusCode: 200,
                                                 httpVersion: nil,
                                                 headerFields: nil)

        var actualProfile: UserProfile?
        var actualError: Error?

        // 3. Call the method
        sut.fetchUserProfile { result in
            switch result {
            case .success(let profile):
                actualProfile = profile
            case .failure(let error):
                actualError = error
            }
            expectation.fulfill()
        }

        // 4. Wait for expectation
        waitForExpectations(timeout: 1.0)

        // 5. Assert URL
        XCTAssertEqual(mockSession.lastURL, expectedURL)

        // 6. Assert resume was called
        XCTAssertTrue(mockSession.nextDataTask.resumeWasCalled)

        // 7. Assert result
        XCTAssertNotNil(actualProfile)
        XCTAssertNil(actualError)
        XCTAssertEqual(actualProfile?.id, "user123")
        XCTAssertEqual(actualProfile?.firstName, "Мария")
        XCTAssertEqual(actualProfile?.email, "maria.test@example.com")
    }

    func testFetchUserProfile_Failure_NetworkError() {
        let expectation = self.expectation(description: "FetchUserProfile network error expectation")
        
        let expectedError = NSError(domain: "NSURLErrorDomain", code: NSURLErrorNotConnectedToInternet, userInfo: nil)
        let expectedURL = APIEnvironment.EndpointPath.userProfile.getURL()!
        mockSession.nextError = expectedError
        mockSession.nextResponse = HTTPURLResponse(url: expectedURL,
                                                 statusCode: 200, 
                                                 httpVersion: nil,
                                                 headerFields: nil)

        var actualProfile: UserProfile?
        var actualError: Error?
        
        sut.fetchUserProfile { result in
            switch result {
            case .success(let profile):
                actualProfile = profile
            case .failure(let error):
                actualError = error
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertEqual(mockSession.lastURL, expectedURL)
        XCTAssertTrue(mockSession.nextDataTask.resumeWasCalled)
        XCTAssertNil(actualProfile)
        XCTAssertNotNil(actualError)
        guard let networkErr = actualError as? NetworkError else {
            XCTFail("Error was not a NetworkError: \(String(describing: actualError))")
            return
        }
        XCTAssertEqual(networkErr, NetworkError.networkRequestFailed(expectedError),
                       "Expected .networkRequestFailed, got \(networkErr.localizedDescription)")
    }

    func testFetchUserProfile_Failure_HTTPError() {
        let expectation = self.expectation(description: "FetchUserProfile HTTP error expectation")
        
        let httpErrorStatusCode = 404
        let expectedURL = APIEnvironment.EndpointPath.userProfile.getURL()!
        mockSession.nextResponse = HTTPURLResponse(url: expectedURL,
                                                 statusCode: httpErrorStatusCode,
                                                 httpVersion: nil,
                                                 headerFields: nil)

        var actualProfile: UserProfile?
        var actualError: Error?
        
        sut.fetchUserProfile { result in
            switch result {
            case .success(let profile):
                actualProfile = profile
            case .failure(let error):
                actualError = error
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertEqual(mockSession.lastURL, expectedURL)
        XCTAssertTrue(mockSession.nextDataTask.resumeWasCalled)
        XCTAssertNil(actualProfile)
        XCTAssertNotNil(actualError)
        guard let networkErr = actualError as? NetworkError else {
            XCTFail("Error was not a NetworkError: \(String(describing: actualError))")
            return
        }
        XCTAssertEqual(networkErr, NetworkError.invalidResponse(statusCode: httpErrorStatusCode),
                       "Expected .invalidResponse with status \(httpErrorStatusCode), got \(networkErr.localizedDescription)")
    }

    func testFetchUserProfile_Failure_NoData() {
        let expectation = self.expectation(description: "FetchUserProfile no data expectation")

        let expectedURL = APIEnvironment.EndpointPath.userProfile.getURL()!
        mockSession.nextData = nil
        mockSession.nextResponse = HTTPURLResponse(url: expectedURL,
                                                 statusCode: 200,
                                                 httpVersion: nil,
                                                 headerFields: nil)
        
        var actualProfile: UserProfile?
        var actualError: Error?
        
        sut.fetchUserProfile { result in
            switch result {
            case .success(let profile):
                actualProfile = profile
            case .failure(let error):
                actualError = error
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertEqual(mockSession.lastURL, expectedURL)
        XCTAssertTrue(mockSession.nextDataTask.resumeWasCalled)
        XCTAssertNil(actualProfile)
        XCTAssertNotNil(actualError)
        guard let networkErr = actualError as? NetworkError else {
            XCTFail("Error was not a NetworkError: \(String(describing: actualError))")
            return
        }
        XCTAssertEqual(networkErr, NetworkError.noData,
                       "Expected .noData, got \(networkErr.localizedDescription)")
    }

    func testFetchUserProfile_Failure_DecodingError() throws {
        let expectation = self.expectation(description: "FetchUserProfile decoding error expectation")
        
        // 1. Prepare malformed mock data
        let malformedJsonString = "{\"id\": \"user123\", \"first_name\": \"Maria\"}" // Malformed: missing other required fields
        let mockJsonData = Data(malformedJsonString.utf8)
        
        let expectedURL = APIEnvironment.EndpointPath.userProfile.getURL()!
        mockSession.nextData = mockJsonData
        mockSession.nextResponse = HTTPURLResponse(url: expectedURL,
                                                 statusCode: 200,
                                                 httpVersion: nil,
                                                 headerFields: nil)
        
        var actualProfile: UserProfile?
        var actualError: Error?
        
        sut.fetchUserProfile { result in
            switch result {
            case .success(let profile):
                actualProfile = profile
            case .failure(let error):
                actualError = error
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertEqual(mockSession.lastURL, expectedURL)
        XCTAssertTrue(mockSession.nextDataTask.resumeWasCalled)
        XCTAssertNil(actualProfile)
        XCTAssertNotNil(actualError)
        guard let networkErr = actualError as? NetworkError else {
            XCTFail("Error was not a NetworkError: \(String(describing: actualError))")
            return
        }
        guard case .decodingError = networkErr else { XCTFail("Expected .decodingError, got \(networkErr)"); return }
    }

    // MARK: - Cities Tests

    func testFetchCities_Success() throws {
        let expectation = self.expectation(description: "FetchCities success expectation")

        // 1. Prepare mock data
        let mockCities = [
            City(id: "city1", name: "Москва", position: CityPosition(lat: "55.7558", long: "37.6173")),
            City(id: "city2", name: "Санкт-Петербург", position: CityPosition(lat: "59.9343", long: "30.3351"))
        ]
        let mockResponse = CitiesResponse(cities: mockCities)
        let mockJsonData = try JSONEncoder().encode(mockResponse)

        // 2. Configure mock session
        let expectedURL = APIEnvironment.EndpointPath.cities.getURL()!
        mockSession.nextData = mockJsonData
        mockSession.nextResponse = HTTPURLResponse(url: expectedURL,
                                                 statusCode: 200,
                                                 httpVersion: nil,
                                                 headerFields: nil)

        var actualCities: [City]?
        var actualError: Error?

        // 3. Call the method
        sut.fetchCities { result in
            switch result {
            case .success(let cities):
                actualCities = cities
            case .failure(let error):
                actualError = error
            }
            expectation.fulfill()
        }

        // 4. Wait for expectation
        waitForExpectations(timeout: 1.0)

        // 5. Assert URL
        XCTAssertEqual(mockSession.lastURL, expectedURL)

        // 6. Assert resume was called
        XCTAssertTrue(mockSession.nextDataTask.resumeWasCalled)

        // 7. Assert result
        XCTAssertNotNil(actualCities)
        XCTAssertNil(actualError)
        XCTAssertEqual(actualCities?.count, 2)
        XCTAssertEqual(actualCities?.first?.name, "Москва")
        XCTAssertEqual(actualCities?.last?.id, "city2")
    }

    func testFetchCities_Failure_NetworkError() {
        let expectation = self.expectation(description: "FetchCities network error expectation")
        
        let expectedError = NSError(domain: "NSURLErrorDomain", code: NSURLErrorNotConnectedToInternet, userInfo: nil)
        let expectedURL = APIEnvironment.EndpointPath.cities.getURL()!
        mockSession.nextError = expectedError
        mockSession.nextResponse = HTTPURLResponse(url: expectedURL,
                                                 statusCode: 200, 
                                                 httpVersion: nil,
                                                 headerFields: nil)

        var actualCities: [City]?
        var actualError: Error?
        
        sut.fetchCities { result in
            switch result {
            case .success(let cities):
                actualCities = cities
            case .failure(let error):
                actualError = error
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertEqual(mockSession.lastURL, expectedURL)
        XCTAssertTrue(mockSession.nextDataTask.resumeWasCalled)
        XCTAssertNil(actualCities)
        XCTAssertNotNil(actualError)
        guard let networkErr = actualError as? NetworkError else {
            XCTFail("Error was not a NetworkError: \(String(describing: actualError))")
            return
        }
        XCTAssertEqual(networkErr, NetworkError.networkRequestFailed(expectedError),
                       "Expected .networkRequestFailed, got \(networkErr.localizedDescription)")
    }

    func testFetchCities_Failure_HTTPError() {
        let expectation = self.expectation(description: "FetchCities HTTP error expectation")
        
        let httpErrorStatusCode = 503
        let expectedURL = APIEnvironment.EndpointPath.cities.getURL()!
        mockSession.nextResponse = HTTPURLResponse(url: expectedURL,
                                                 statusCode: httpErrorStatusCode,
                                                 httpVersion: nil,
                                                 headerFields: nil)

        var actualCities: [City]?
        var actualError: Error?
        
        sut.fetchCities { result in
            switch result {
            case .success(let cities):
                actualCities = cities
            case .failure(let error):
                actualError = error
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertEqual(mockSession.lastURL, expectedURL)
        XCTAssertTrue(mockSession.nextDataTask.resumeWasCalled)
        XCTAssertNil(actualCities)
        XCTAssertNotNil(actualError)
        guard let networkErr = actualError as? NetworkError else {
            XCTFail("Error was not a NetworkError: \(String(describing: actualError))")
            return
        }
        XCTAssertEqual(networkErr, NetworkError.invalidResponse(statusCode: httpErrorStatusCode),
                       "Expected .invalidResponse with status \(httpErrorStatusCode), got \(networkErr.localizedDescription)")
    }

    func testFetchCities_Failure_NoData() {
        let expectation = self.expectation(description: "FetchCities no data expectation")

        let expectedURL = APIEnvironment.EndpointPath.cities.getURL()!
        mockSession.nextData = nil
        mockSession.nextResponse = HTTPURLResponse(url: expectedURL,
                                                 statusCode: 200,
                                                 httpVersion: nil,
                                                 headerFields: nil)
        
        var actualCities: [City]?
        var actualError: Error?
        
        sut.fetchCities { result in
            switch result {
            case .success(let cities):
                actualCities = cities
            case .failure(let error):
                actualError = error
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertEqual(mockSession.lastURL, expectedURL)
        XCTAssertTrue(mockSession.nextDataTask.resumeWasCalled)
        XCTAssertNil(actualCities)
        XCTAssertNotNil(actualError)
        guard let networkErr = actualError as? NetworkError else {
            XCTFail("Error was not a NetworkError: \(String(describing: actualError))")
            return
        }
        XCTAssertEqual(networkErr, NetworkError.noData,
                       "Expected .noData, got \(networkErr.localizedDescription)")
    }

    func testFetchCities_Failure_DecodingError() throws {
        let expectation = self.expectation(description: "FetchCities decoding error expectation")
        
        // 1. Prepare malformed mock data
        let malformedJsonString = "{\"cities\": [{\"id\": \"city1\", \"name\": \"Malformed City\"}]}" // Malformed: e.g. city might expect 'position'
        let mockJsonData = Data(malformedJsonString.utf8)
        
        // 2. Configure mock session
        let expectedURL = APIEnvironment.EndpointPath.cities.getURL()!
        mockSession.nextData = mockJsonData
        mockSession.nextResponse = HTTPURLResponse(url: expectedURL,
                                                 statusCode: 200,
                                                 httpVersion: nil,
                                                 headerFields: nil)
        
        var actualCities: [City]?
        var actualError: Error?
        
        // 3. Call the method
        sut.fetchCities { result in
            switch result {
            case .success(let cities):
                actualCities = cities
            case .failure(let error):
                actualError = error
            }
            expectation.fulfill()
        }
        
        // 4. Wait for expectation
        waitForExpectations(timeout: 1.0)
        
        // 5. Assert URL
        XCTAssertEqual(mockSession.lastURL, expectedURL)
        
        // 6. Assert resume was called
        XCTAssertTrue(mockSession.nextDataTask.resumeWasCalled)
        
        // 7. Assert result
        XCTAssertNil(actualCities)
        XCTAssertNotNil(actualError)
        guard let networkErr = actualError as? NetworkError else {
            XCTFail("Error was not a NetworkError: \(String(describing: actualError))")
            return
        }
        guard case .decodingError = networkErr else { XCTFail("Expected .decodingError, got \(networkErr)"); return }
    }

    // MARK: - Create Event Tests

    func testCreateEvent_Success() {
        let expectation = self.expectation(description: "CreateEvent success expectation")
        
        let eventName = "Новое Мероприятие"
        let eventDate = Date()
        let eventCity = "Новый Город"
        
        var createdEvent: Event?
        var actualError: Error?
        
        // To make this test deterministic and not rely on the 5% random failure,
        // we might need to refactor NetworkService.createEvent to allow injecting the random number generator
        // or a boolean flag to force success/failure for testing. 
        // For now, we accept that this test might occasionally (5% of the time) fail due to the simulated network error.
        // A more robust approach for production code would be to make randomness injectable.

        sut.createEvent(name: eventName, 
                        date: eventDate, 
                        city: eventCity, 
                        category: "Тест", 
                        description: "Описание", 
                        organizer: "Организатор") { result in
            switch result {
            case .success(let event):
                createdEvent = event
            case .failure(let error):
                actualError = error
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0) // Increased timeout due to 1.5s simulated delay
        
        // If the 5% random failure occurred, this assertion will fail.
        XCTAssertNotNil(createdEvent, "Event creation failed, possibly due to simulated random network error. Error: \(actualError?.localizedDescription ?? "Unknown error")")
        XCTAssertNil(actualError)
        XCTAssertEqual(createdEvent?.name, eventName)
        XCTAssertEqual(createdEvent?.city, eventCity)
        // Date comparison can be tricky due to precision, let's check roughly
        if let createdDate = createdEvent?.date {
             XCTAssertTrue(abs(createdDate.timeIntervalSince(eventDate)) < 0.001, "Event date does not match")
        }
        XCTAssertEqual(createdEvent?.category, "Тест")
    }

    func testCreateEvent_Failure_EmptyName() {
        let expectation = self.expectation(description: "CreateEvent empty name validation expectation")
        
        var createdEvent: Event?
        var actualError: Error?
        
        sut.createEvent(name: "", // Empty name
                        date: Date(), 
                        city: "Город", 
                        category: "Тест", 
                        description: "Описание", 
                        organizer: "Организатор") { result in
            switch result {
            case .success(let event):
                createdEvent = event
            case .failure(let error):
                actualError = error
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0) 
        
        XCTAssertNil(createdEvent)
        XCTAssertNotNil(actualError)
        guard let networkErr = actualError as? NetworkError else {
            XCTFail("Error was not a NetworkError: \(String(describing: actualError))")
            return
        }
        XCTAssertEqual(networkErr, NetworkError.validationError("Server validation: Event name and city cannot be empty."),
                       "Expected validation error for empty name.")
    }

    func testCreateEvent_Failure_EmptyCity() {
        let expectation = self.expectation(description: "CreateEvent empty city validation expectation")
        
        var createdEvent: Event?
        var actualError: Error?
        
        sut.createEvent(name: "Имя События", 
                        date: Date(), 
                        city: "", // Empty city
                        category: "Тест", 
                        description: "Описание", 
                        organizer: "Организатор") { result in
            switch result {
            case .success(let event):
                createdEvent = event
            case .failure(let error):
                actualError = error
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0)
        
        XCTAssertNil(createdEvent)
        XCTAssertNotNil(actualError)
        guard let networkErr = actualError as? NetworkError else {
            XCTFail("Error was not a NetworkError: \(String(describing: actualError))")
            return
        }
        XCTAssertEqual(networkErr, NetworkError.validationError("Server validation: Event name and city cannot be empty."),
                       "Expected validation error for empty city.")
    }

    // MARK: - Register For Event Tests

    func testRegisterForEvent_Success() {
        let expectation = self.expectation(description: "RegisterForEvent success expectation")
        
        let eventId = UUID()
        let userId = "testUser123"
        
        var successResult: Bool?
        var actualError: Error?
        
        // Similar to createEvent, this test has a small chance (3%) of failing due to simulated error.
        // Ideally, randomness should be injectable for deterministic tests.

        sut.registerForEvent(eventId: eventId, userId: userId) { result in
            switch result {
            case .success(let success):
                successResult = success
            case .failure(let error):
                actualError = error
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.5) // Simulated delay is 1.0s
        
        // If the 3% random failure occurred, this assertion might fail.
        XCTAssertEqual(successResult, true, "Registration failed, possibly due to simulated random error. Error: \(actualError?.localizedDescription ?? "Unknown error")")
        XCTAssertNil(actualError)
    }

    // MARK: - Bot Message Tests

    func testFetchBotMessageResponse_Success() throws {
        let expectation = self.expectation(description: "FetchBotMessageResponse success expectation")
        
        // 1. Prepare mock data
        let mockMessage = ServerChatMessage(text: "Привет! Как я могу помочь?", user: "Bot")
        let mockJsonData = try JSONEncoder().encode(mockMessage)
        
        // 2. Configure mock session
        let expectedURL = APIEnvironment.EndpointPath.message.getURL()!
        mockSession.nextData = mockJsonData
        mockSession.nextResponse = HTTPURLResponse(url: expectedURL,
                                                 statusCode: 200,
                                                 httpVersion: nil,
                                                 headerFields: nil)
        
        var actualMessage: ServerChatMessage?
        var actualError: Error?
        
        // 3. Call the method
        sut.fetchBotMessageResponse { result in
            switch result {
            case .success(let message):
                actualMessage = message
            case .failure(let error):
                actualError = error
            }
            expectation.fulfill()
        }
        
        // 4. Wait for expectation
        waitForExpectations(timeout: 1.0)
        
        // 5. Assert URL
        XCTAssertEqual(mockSession.lastURL, expectedURL)
        
        // 6. Assert resume was called
        XCTAssertTrue(mockSession.nextDataTask.resumeWasCalled)
        
        // 7. Assert result
        XCTAssertNotNil(actualMessage)
        XCTAssertNil(actualError)
        XCTAssertEqual(actualMessage?.text, "Привет! Как я могу помочь?")
        XCTAssertEqual(actualMessage?.user, "Bot")
    }

    func testFetchBotMessageResponse_Failure_NetworkError() {
        let expectation = self.expectation(description: "FetchBotMessageResponse network error")
        
        let expectedError = NSError(domain: "NSURLErrorDomain", code: NSURLErrorCannotConnectToHost, userInfo: nil)
        let expectedURL = APIEnvironment.EndpointPath.message.getURL()!
        mockSession.nextError = expectedError
        mockSession.nextResponse = HTTPURLResponse(url: expectedURL, statusCode: 200, httpVersion: nil, headerFields: nil)

        var actualMessage: ServerChatMessage?
        var actualError: Error?
        
        sut.fetchBotMessageResponse { result in
            if case .success(let msg) = result { actualMessage = msg }
            if case .failure(let err) = result { actualError = err }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertEqual(mockSession.lastURL, expectedURL)
        XCTAssertTrue(mockSession.nextDataTask.resumeWasCalled)
        XCTAssertNil(actualMessage)
        XCTAssertNotNil(actualError)
        guard let networkErr = actualError as? NetworkError else {
            XCTFail("Error was not a NetworkError: \(String(describing: actualError))")
            return
        }
        XCTAssertEqual(networkErr, NetworkError.networkRequestFailed(expectedError),
                       "Expected .networkRequestFailed(\(expectedError.localizedDescription)), got \(networkErr.localizedDescription)")
    }

    func testFetchBotMessageResponse_Failure_HTTPError() {
        let expectation = self.expectation(description: "FetchBotMessageResponse HTTP error")
        
        let httpErrorStatusCode = 401
        let expectedURL = APIEnvironment.EndpointPath.message.getURL()!
        mockSession.nextResponse = HTTPURLResponse(url: expectedURL, statusCode: httpErrorStatusCode, httpVersion: nil, headerFields: nil)

        var actualMessage: ServerChatMessage?
        var actualError: Error?
        
        sut.fetchBotMessageResponse { result in
            if case .success(let msg) = result { actualMessage = msg }
            if case .failure(let err) = result { actualError = err }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertEqual(mockSession.lastURL, expectedURL)
        XCTAssertTrue(mockSession.nextDataTask.resumeWasCalled)
        XCTAssertNil(actualMessage)
        XCTAssertNotNil(actualError)
        guard let networkErr = actualError as? NetworkError else {
            XCTFail("Error was not a NetworkError: \(String(describing: actualError))")
            return
        }
        XCTAssertEqual(networkErr, NetworkError.invalidResponse(statusCode: httpErrorStatusCode),
                       "Expected .invalidResponse with status \(httpErrorStatusCode), got \(networkErr.localizedDescription)")
    }

    func testFetchBotMessageResponse_Failure_NoData() {
        let expectation = self.expectation(description: "FetchBotMessageResponse no data")

        let expectedURL = APIEnvironment.EndpointPath.message.getURL()!
        mockSession.nextData = nil
        mockSession.nextResponse = HTTPURLResponse(url: expectedURL, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        var actualMessage: ServerChatMessage?
        var actualError: Error?
        
        sut.fetchBotMessageResponse { result in
            if case .success(let msg) = result { actualMessage = msg }
            if case .failure(let err) = result { actualError = err }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertEqual(mockSession.lastURL, expectedURL)
        XCTAssertTrue(mockSession.nextDataTask.resumeWasCalled)
        XCTAssertNil(actualMessage)
        XCTAssertNotNil(actualError)
        guard let networkErr = actualError as? NetworkError else {
            XCTFail("Error was not a NetworkError: \(String(describing: actualError))")
            return
        }
        XCTAssertEqual(networkErr, NetworkError.noData,
                       "Expected .noData, got \(networkErr.localizedDescription)")
    }

    func testFetchBotMessageResponse_Failure_DecodingError() throws {
        let expectation = self.expectation(description: "FetchBotMessageResponse decoding error")
        
        let malformedJsonString = "{\"text\": \"Hello there!\"}" // Malformed: missing 'user' field
        let mockJsonData = Data(malformedJsonString.utf8)
        
        let expectedURL = APIEnvironment.EndpointPath.message.getURL()!
        mockSession.nextData = mockJsonData
        mockSession.nextResponse = HTTPURLResponse(url: expectedURL, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        var actualMessage: ServerChatMessage?
        var actualError: Error?
        
        sut.fetchBotMessageResponse { result in
            if case .success(let msg) = result { actualMessage = msg }
            if case .failure(let err) = result { actualError = err }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertEqual(mockSession.lastURL, expectedURL)
        XCTAssertTrue(mockSession.nextDataTask.resumeWasCalled)
        XCTAssertNil(actualMessage)
        XCTAssertNotNil(actualError)
        guard let networkErr = actualError as? NetworkError else {
            XCTFail("Error was not a NetworkError: \(String(describing: actualError))")
            return
        }
        guard case .decodingError = networkErr else { XCTFail("Expected .decodingError, got \(networkErr)"); return }
    }

}

// MARK: - Mocks for URLSession
// The following protocols and extensions were moved to NetworkService.swift
// protocol URLSessionProtocol { ... removed ... }
// protocol URLSessionDataTaskProtocol { ... removed ... }
// extension URLSession: URLSessionProtocol { ... removed ... }
// extension URLSessionDataTask: URLSessionDataTaskProtocol { ... removed ... }

class MockURLSession: URLSessionProtocol {
    var nextDataTask = MockURLSessionDataTask()
    var nextData: Data?
    var nextResponse: URLResponse?
    var nextError: Error?
    
    private (set) var lastURL: URL?
    
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        lastURL = url
        completionHandler(nextData, nextResponse, nextError)
        return nextDataTask
    }
}

class MockURLSessionDataTask: URLSessionDataTaskProtocol {
    private (set) var resumeWasCalled = false
    func resume() {
        resumeWasCalled = true
    }
}

// MARK: - APIEnvironmentTests
class APIEnvironmentTests: XCTestCase {

    func testAPIEnvironment_EventsURL() {
        let expectedURLString = "https://r2.mocker.surfstudio.ru/qa_trainee/events"
        XCTAssertEqual(APIEnvironment.EndpointPath.events.getURL()?.absoluteString, expectedURLString)
    }

    func testAPIEnvironment_UserProfileURL() {
        let expectedURLString = "https://r2.mocker.surfstudio.ru/qa_trainee/user/profile"
        XCTAssertEqual(APIEnvironment.EndpointPath.userProfile.getURL()?.absoluteString, expectedURLString)
    }

    func testAPIEnvironment_CitiesURL() {
        let expectedURLString = "https://r2.mocker.surfstudio.ru/qa_trainee/cities"
        XCTAssertEqual(APIEnvironment.EndpointPath.cities.getURL()?.absoluteString, expectedURLString)
    }

    func testAPIEnvironment_MessageURL() {
        let expectedURLString = "https://r2.mocker.surfstudio.ru/qa_trainee/message"
        XCTAssertEqual(APIEnvironment.EndpointPath.message.getURL()?.absoluteString, expectedURLString)
    }
    
    func testAPIEnvironment_BaseURLConstant() {
        XCTAssertEqual(APIEnvironment.baseURLString, "https://r2.mocker.surfstudio.ru/qa_trainee")
    }

} 
