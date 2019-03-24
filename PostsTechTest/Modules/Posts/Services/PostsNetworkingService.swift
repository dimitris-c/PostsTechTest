import Foundation
import RxSwift

protocol PostsNetworking {
    func getPosts() -> Observable<[Post]>
    func getUsers() -> Observable<[User]>
    func getComments(postId: Identifier<Post>) -> Observable<[Comment]>
}

final class PostsNetworkingService: PostsNetworking {
    
    private let networking: Networking
    private let baseURL: URL
    
    init(networking: Networking, baseURL: URL) {
        self.networking = networking
        self.baseURL = baseURL
    }
    
    func getPosts() -> Observable<[Post]> {
        let endpoint = Endpoint<[Post]>(path: "/posts")
        return self.networking.request(endpoint, baseURL: self.baseURL)
            .map { $0.result }
    }
    
    func getUsers() -> Observable<[User]> {
        let endpoint = Endpoint<[User]>(method: .get, path: "/users")
        return self.networking.request(endpoint, baseURL: self.baseURL)
            .map { $0.result }
    }
    
    func getComments(postId: Identifier<Post>) -> Observable<[Comment]> {
        let endpoint = Endpoint<[Comment]>(method: .get, path: "/comments", queries: ["postId": "\(postId.value)"])
        return self.networking.request(endpoint, baseURL: self.baseURL)
            .map { $0.result }
    }
}
