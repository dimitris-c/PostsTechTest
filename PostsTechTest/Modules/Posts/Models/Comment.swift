import Foundation

struct Comment: Codable, Equatable, Identifiable {
    typealias RawIdentifier = Int
    
    let postId: Identifier<Post>
    let id: Identifier<Comment>
    let name: String
    let email: String
    let body: String
}
