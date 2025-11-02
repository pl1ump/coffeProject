import Foundation
import CoreLocation
import MapKit

@MainActor
protocol MapViewModelProtocol: ObservableObject {
    var coffeeShops: [Business] { get }
    var userLocation: CLLocationCoordinate2D? { get }
    var region: MKCoordinateRegion { get set }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    var searchRadius: Int { get set }
    var alertWrapper: AlertWrapper? { get set }

    func requestLocationPermission()
    func loadCoffeeShops() async
}
