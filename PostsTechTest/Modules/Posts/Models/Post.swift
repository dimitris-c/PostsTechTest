import Foundation

struct Post: Codable, Equatable, Identifiable {
    typealias RawIdentifier = Int
    
    let userId: Identifier<User>
    let id: Identifier<Post>
    let title: String
    let body: String
}
