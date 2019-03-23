import Foundation
import RxSwift
import RxCocoa

protocol NetworkingSession {
    func response(request: URLRequest) -> Observable<(response: HTTPURLResponse, data: Data)>
}

extension URLSession: NetworkingSession {
    func response(request: URLRequest) -> Observable<(response: HTTPURLResponse, data: Data)> {
        return self.rx.response(request: request)
    }
}
