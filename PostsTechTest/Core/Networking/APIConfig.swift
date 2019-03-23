import Foundation

enum APIConfig {
    case staging
    
    var baseURL: URL? {
        switch self {
        case .staging:
            return URL(string: "https://jsonplaceholder.typicode.com")
        }
    }
}
