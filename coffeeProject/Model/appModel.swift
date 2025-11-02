import Foundation
import CoreLocation

// MARK: - Response Root
struct YelpSearchResponse: Decodable {
    let total: Int
    let businesses: [Business]
}

// MARK: - Business
struct Business: Identifiable, Decodable {
    let id: String
    let name: String
    let imageUrl: URL?
    let url: URL?
    let rating: Double?
    let reviewCount: Int?
    let price: String?
    let phone: String?
    let distance: Double?
    let categories: [Category]
    let coordinates: Coordinate
    let location: Location

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coordinates.latitude,
                               longitude: coordinates.longitude)
    }
}

// MARK: - Category
struct Category: Decodable {
    let alias: String
    let title: String
}

// MARK: - Coordinate
struct Coordinate: Decodable {
    let latitude: Double
    let longitude: Double
}

// MARK: - Location
struct Location: Decodable {
    let address1: String?
    let address2: String?
    let address3: String?
    let city: String?
    let state: String?
    let zipCode: String?
    let country: String?

    
    var fullAddress: String {
        [address1, address2, address3]
            .compactMap { $0 }
            .joined(separator: ", ") +
        (city.map { ", \($0)" } ?? "") +
        (state.map { ", \($0)" } ?? "") +
        (zipCode.map { " \($0)" } ?? "")
    }
}

