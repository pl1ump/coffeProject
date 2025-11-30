import Foundation
import MapKit


struct CoffeShopViewData {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let distanceText: String?
    let imageURL: URL?
    let rating: Double?
    let reviewCount: Int?
    let photos: [String]?
    let location: Location
}
