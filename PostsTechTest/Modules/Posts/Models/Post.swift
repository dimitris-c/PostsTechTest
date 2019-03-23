import Foundation

struct Post: Codable, Equatable {
    let userId: String
    let id: String
    let title: String
    let body: String
}
