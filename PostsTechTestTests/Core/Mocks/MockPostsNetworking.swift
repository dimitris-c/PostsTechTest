import Foundation
import RxSwift

@testable import PostsTechTest

class MockPostsNetworking: PostsNetworking {
    
    var posts: Observable<[Post]> = .just([])
    func getPosts() -> Observable<[Post]> {
        return posts
    }
    
    var users: Observable<[User]> = .just([])
    func getUsers() -> Observable<[User]> {
        return users
    }
    
    var comments: Observable<[Comment]> = .just([])
    func getComments(postId: Identifier<Post>) -> Observable<[Comment]> {
        return comments
    }
    
    
}
