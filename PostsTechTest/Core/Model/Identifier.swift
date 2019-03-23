import Foundation

public protocol Identifiable {
    associatedtype RawIdentifier: Codable & Hashable = String
    
    var id: Identifier<Self> { get }
}

public struct Identifier<Value: Identifiable>: Codable, Equatable {
    public let value: Value.RawIdentifier
    
    public init(value: Value.RawIdentifier) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try container.decode(Value.RawIdentifier.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

extension Identifier: ExpressibleByIntegerLiteral where Value.RawIdentifier == Int {
    public typealias IntegerLiteralType = Int
    
    public init(integerLiteral value: Int) {
        self.value = value
    }
}
