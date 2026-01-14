import Foundation
import CoreLocation
import MapKit

@MainActor
final class MapViewModel: NSObject, MapViewModelProtocol {
    
    @Published var coffeeShops: [CoffeShopViewData] = []
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var region = MKCoordinateRegion()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchRadius: Int {
        didSet {
            UserDefaults.standard.set(searchRadius, forKey: "searchRadius")
        }
    }
    @Published var alertWrapper: AlertWrapper? = nil
    @Published var selectedShop: Business?
    
    // MARK: - Dependencies
    private let service: YelpService
    private let locationManager = CLLocationManager()
    
    // MARK: - Init network manager
    init(service: YelpService) {
        self.service = service
        self.searchRadius = UserDefaults.standard.integer(forKey: "searchRadius")
        super.init()
        locationManager.delegate = self
    }
    
    // MARK: - Location permission
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Load Coffee Shops
    func loadCoffeeShops() async {
        guard let userLocation else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let shops = try await service.searchCoffeeShops(
                latitude: userLocation.latitude,
                longitude: userLocation.longitude,
                radius: searchRadius,
                limit: 20
            )
            
            let viewData = shops.map { mapToViewData(from: $0) }
            
            await MainActor.run {
                self.coffeeShops = viewData
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func searchAddress(_ address: String) async {
        guard !address.isEmpty else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        let geocoder = CLGeocoder()
        
        do {
            let placemarks = try await geocoder.geocodeAddressString(address)
            
            if let location = placemarks.first?.location?.coordinate {
                userLocation = location
                region = MKCoordinateRegion(
                    center: location,
                    span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
                await loadCoffeeShops()
            }
        } catch {
            errorMessage = "Address not found"
        }
    }
    
    func mapToViewData(from business: Business) -> CoffeShopViewData {
        CoffeShopViewData(
            id: business.id,
            name: business.name,
            coordinate: business.coordinate,
            distanceText: business.distance.map { "\($0 / 1000) km" },
            imageURL: business.imageUrl.flatMap(URL.init(string:)),
            rating: business.rating,
            reviewCount: business.reviewCount,
            photos: business.photos,
            location: business.location
        )
    }
    
    func showError(_ message: String) {
        alertWrapper = AlertWrapper(title: "Error", message: message)
    }
    
    
}

extension MapViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard userLocation == nil else { return }
        
        if let location = locations.last {
            let coordinate = location.coordinate
            userLocation = coordinate
            
            region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Location error: \(error.localizedDescription)"
    }
}
