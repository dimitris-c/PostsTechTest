import Foundation

public enum DataServiceError: Equatable, Error {
    case networking(_ error: Error)
    
    public static func ==(lhs: DataServiceError, rhs: DataServiceError) -> Bool {
        switch (lhs, rhs) {
        case (.networking, .networking):
            return true
        default: return false
        }
    }
}

public enum GenericState<T: Equatable>: Equatable {
    case error(error: DataServiceError)
    case loading
    case loaded(item: T)
    public typealias Item = T

    public var item: T? {
        if case let .loaded(loadedItem) = self {
            return loadedItem
        }
        return nil
    }
    
    public var isLoading: Bool {
        return self == .loading
    }
}
