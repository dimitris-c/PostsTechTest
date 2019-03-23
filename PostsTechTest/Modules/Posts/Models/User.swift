import Foundation

struct User: Codable, Equatable, Identifiable {
    typealias RawIdentifier = Int
    
    let id: Identifier<User>
    let name: String
    let username: String
    let email: String
}
