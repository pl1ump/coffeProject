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
    let imageUrl: String?
    let url: URL?
    let rating: Double?
    let reviewCount: Int?
    let price: String?
    let phone: String?
    let distance: Double?
    let categories: [Category]
    let coordinates: Coordinate
    let location: Location
    let photos: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case imageUrl = "image_url"
        case url
        case rating
        case reviewCount
        case price
        case phone
        case distance
        case categories
        case coordinates
        case location
        case photos
        
    }
    
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coordinates.latitude,
                               longitude: coordinates.longitude)
    }
}


extension Business: Equatable {
    static func == (lhs: Business, rhs: Business) -> Bool {
        lhs.id == rhs.id
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

// MARK: - Alert
struct AlertWrapper: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

// MARK: - Preview extention
#if DEBUG
extension Business {
    static let preview: Business = Business(
        id: "preview-id",
        name: "Preview Coffee Shop",
        imageUrl: "https://images.pexels.com/photos/302899/pexels-photo-302899.jpeg",
        url: nil,
        rating: 4.7,
        reviewCount: 120,
        price: "$$",
        phone: "+15550123456",
        distance: 120,
        categories: [],
        coordinates: Coordinate(latitude: 37.7749, longitude: -122.4194),
        location: Location(address1: "Market St", address2: nil, address3: nil, city: "San Francisco", state: "CA", zipCode: "94103", country: "USA"),
        photos: []
    )
}
#endif


