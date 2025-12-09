import Foundation
import MapKit


struct CoffeShopViewData: Identifiable, Equatable {
    static func == (lhs: CoffeShopViewData, rhs: CoffeShopViewData) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let distance: Double?
    let imageURL: URL?
    let rating: Double?
    let reviewCount: Int?
    let photos: [String]?
    let location: Location
}

// MARK: - Preview extention
#if DEBUG
extension CoffeShopViewData {
    static let preview: CoffeShopViewData = CoffeShopViewData(
        id: "preview-id",
        name: "Preview Coffee Shop",
        coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        distance: 120.0,
        imageURL: URL(string:"https://images.pexels.com/photos/302899/pexels-photo-302899.jpeg"),
        rating: 4.7,
        reviewCount: 120,
        photos: [],
        location: Location(
            address1: "Market St",
            address2: nil,
            address3: nil,
            city: "San Francisco",
            state: "CA",
            zipCode: "94103",
            country: "USA"
        )
    )

}
#endif
