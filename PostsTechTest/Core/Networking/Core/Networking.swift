import Foundation
import RxSwift

public protocol Networking {
    func request<Response>(_ endpoint: Endpoint<Response>, baseURL: URL) -> Single<(response: HTTPURLResponse, result: Response)>
    func request<Response>(_ endpoint: Endpoint<Response>, baseURL: URL) -> Observable<(response: HTTPURLResponse, result: Response)>
}

final class NetworkingClient: Networking {
    private let session: NetworkingSession
    init(session: NetworkingSession = URLSession.shared) {
        self.session = session
    }
    
    func request<Response>(_ endpoint: Endpoint<Response>, baseURL: URL) -> Observable<(response: HTTPURLResponse, result: Response)> {
        let url = self.url(from: endpoint.path, queries: endpoint.queries, baseURL: baseURL)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.value
        request.cachePolicy = endpoint.cachePolicy
        request.allHTTPHeaderFields = endpoint.parameters
        
        return self.session.response(request: request)
            .map { (response, data) -> (HTTPURLResponse, Response) in
                let result = try endpoint.decode(data)
                return (response: response, result: result)
            }
    }
    
    func request<Response>(_ endpoint: Endpoint<Response>, baseURL: URL) -> Single<(response: HTTPURLResponse, result: Response)> {
        return self.request(endpoint, baseURL: baseURL).asSingle()
    }
    
    private func url(from path: Path, queries: Codable?, baseURL: URL) -> URL {
        guard var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            return baseURL.appendingPathComponent(path)
        }
        urlComponents.path = path
        
        var queryValues:[String: String] = [:]
        if let enpointQueries = queries?.dictionary {
            queryValues = enpointQueries
        }
        if !queryValues.isEmpty {
            let queryItems = queryValues.map { (key, value) in
                return URLQueryItem(name: key, value: value)
            }
            urlComponents.queryItems = queryItems
        }
        return urlComponents.url ?? baseURL
    }
}
