import XCTest
@testable import coffeeProject

final class YelpNetworkManagerTests: XCTestCase {
    
    var sut: YelpNetworkManager!
    var mockSession: MockURLProtocol.Type!
    
    override func setUp() {
        super.setUp()
        mockSession = MockURLProtocol.self
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        
        let mockNetworkManager = YelpNetworkManager(apiKey: "fake_api_key")
        sut = mockNetworkManager
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_searchCoffeeShops_success() async throws {
        let mockJSON = """
        {
            "total": 1,
            "businesses": [
                {
                    "id": "1",
                    "name": "Test Coffee",
                    "image_url": "https://test.com/image.jpg",
                    "url": "https://test.com",
                    "rating": 4.5,
                    "review_count": 100,
                    "price": "$$",
                    "phone": "123456",
                    "distance": 120.5,
                    "categories": [],
                    "coordinates": {
                        "latitude": 37.77,
                        "longitude": -122.41
                    },
                    "location": {
                        "address1": "Main St",
                        "city": "San Francisco",
                        "state": "CA",
                        "zip_code": "94103",
                        "country": "US"
                    },
                    "photos": []
                }
            ]
        }
        """.data(using: .utf8)!

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, mockJSON)
        }

        let sut = YelpNetworkManager(apiKey: "test_api_key", session: session)
        
        let result = try await sut.searchCoffeeShops(latitude: 37.77, longitude: -122.41)
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "Test Coffee")
    }

}
