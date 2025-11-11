import Foundation
@testable import coffeeProject

final class MockYelpService: YelpService {
    var shouldFail = false
    
    init(shouldFail: Bool = false) {
        self.shouldFail = shouldFail
    }
    
    func searchCoffeeShops(latitude: Double,
                           longitude: Double,
                           radius: Int,
                           limit: Int) async throws -> [Business] {
        if shouldFail {
            throw NSError(domain: "MockError", code: 500)
        } else {
            return [
                Business.preview,
                Business.preview
            ]
        }
    }
}
