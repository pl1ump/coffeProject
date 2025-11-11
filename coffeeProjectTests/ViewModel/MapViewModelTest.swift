import XCTest
@testable import coffeeProject
import CoreLocation


final class MapViewModelTests: XCTestCase {
    @MainActor
    func test_loadCoffeeShops_success() async {
        let mockService = MockYelpService()
        let sut = MapViewModel(service: mockService)
        sut.userLocation = CLLocationCoordinate2D(latitude: 10, longitude: 20)
        
        await sut.loadCoffeeShops()
        
        XCTAssertEqual(sut.coffeeShops.count, 2)
        XCTAssertNil(sut.errorMessage)
    }
    @MainActor
    func test_loadCoffeeShops_failure() async {
        let mockService = MockYelpService(shouldFail: true)
        let sut = MapViewModel(service: mockService)
        sut.userLocation = CLLocationCoordinate2D(latitude: 10, longitude: 20)
        
        await sut.loadCoffeeShops()
        
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.errorMessage?.contains("Mock") ?? false)
    }
}
