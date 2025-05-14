import Foundation

// City related data structures

struct CityPosition: Codable, Hashable {
    let lat: String
    let long: String
}

struct City: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let position: CityPosition
}

struct CitiesResponse: Codable {
    let cities: [City]
} 