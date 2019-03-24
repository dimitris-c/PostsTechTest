import Foundation

@testable import PostsTechTest

class MockPostsPersistance: PostsPersistanceType {
    
    var posts: [Post]? = nil
    func getPosts() -> [Post]? {
        return posts
    }
    
    var savePostsSpy: (called: Bool, posts: [Post]) = (false, [])
    func savePosts(posts: [Post]) {
        savePostsSpy = (true, posts)
    }
    
    var users: [User]? = nil
    func getUsers() -> [User]? {
        return users
    }
    
    var saveUsersSpy: (called: Bool, posts: [User]) = (false, [])
    func saveUsers(users: [User]) {
        saveUsersSpy = (true, users)
    }
    
    var comments: [Comment]? = nil
    func getComments(postId: Identifier<Post>) -> [Comment]? {
        return comments
    }
    
    var saveCommentsSpy: (called: Bool, comments: [Comment]) = (false, [])
    func saveComments(for postId: Identifier<Post>, comments: [Comment]) {
        saveCommentsSpy = (true, comments)
    }
    
}
