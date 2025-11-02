import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case transportError(Error)          // network error
    case decodingError(Error)           // JSON decode failed
    case unauthorized(message: String?) // 401
    case notFound(message: String?)     // 404
    case rateLimited(message: String?)  // 429
    case serverError(statusCode: Int, message: String?) // 5xx
    case clientError(statusCode: Int, message: String?) // 4xx, other
    case unknown(statusCode: Int, message: String?)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Wrong URL"
        case .noData: return "No data from server"
        case .transportError(let e): return e.localizedDescription
        case .decodingError: return "Data error"
        case .unauthorized(let m): return m ?? "Error 401: non authorization"
        case .notFound(let m): return m ?? "Error 404: Not found"
        case .rateLimited(let m): return m ?? "Error 429: To many requests"
        case .serverError(let code, let m): return m ?? "Server erroe (\(code))"
        case .clientError(let code, let m): return m ?? "Client error (\(code))"
        case .unknown(let code, let m): return m ?? "Error (\(code))"
        }
    }
}
