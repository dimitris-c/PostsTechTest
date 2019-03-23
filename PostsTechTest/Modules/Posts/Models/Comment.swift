import Foundation

struct Comment: Codable, Equatable {
    let postId: String
    let id: String
    let name: String
    let email: String
    let body: String
}
