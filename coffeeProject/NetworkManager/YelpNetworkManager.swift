import Foundation

protocol YelpService {
    func searchCoffeeShops(latitude: Double,
                           longitude: Double,
                           radius: Int,
                           limit: Int) async throws -> [Business]
}

class YelpNetworkManager: YelpService {
    private let apiKey: String
    private let session: URLSession
    init(apiKey: String? = nil, session: URLSession = .shared) {
        if let key = apiKey {
            self.apiKey = key
        } else {
            guard let key = Bundle.main.object(forInfoDictionaryKey: "API_KEY_Yelp") as? String else {
                fatalError("Error: API_KEY_Yelp not found in Info.plist")
            }
            self.apiKey = key
        }
        self.session = session
    }
    
    private func fetchData(with request: URLRequest) async throws -> Data {
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.noData
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                return data
            case 401:
                let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
                throw NetworkError.unauthorized(message: apiError?.message)
            case 404:
                let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
                throw NetworkError.notFound(message: apiError?.message)
            case 429:
                let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
                throw NetworkError.rateLimited(message: apiError?.message)
            case 400...499:
                let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
                throw NetworkError.clientError(statusCode: httpResponse.statusCode, message: apiError?.message)
            case 500...599:
                let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
                throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: apiError?.message)
            default:
                let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
                throw NetworkError.unknown(statusCode: httpResponse.statusCode, message: apiError?.message)
            }
        }
        catch {
            throw NetworkError.transportError(error)
        }
        
    }
    
    func searchCoffeeShops(latitude: Double,
                              longitude: Double,
                              radius: Int = 1500,  // meters
                              limit: Int = 20) async throws -> [Business] {
           
           var components = URLComponents(string: "https://api.yelp.com/v3/businesses/search")!
           components.queryItems = [
               URLQueryItem(name: "term", value: "coffee"),
               URLQueryItem(name: "latitude", value: "\(latitude)"),
               URLQueryItem(name: "longitude", value: "\(longitude)"),
               URLQueryItem(name: "radius", value: "\(radius)"),
               URLQueryItem(name: "limit", value: "\(limit)")
           ]
           
           guard let url = components.url else {
               throw NetworkError.invalidURL
           }
           
           var request = URLRequest(url: url)
           request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
           
           let data = try await fetchData(with: request)
           let decoded = try JSONDecoder().decode(YelpSearchResponse.self, from: data)
           return decoded.businesses
       }
    
}
