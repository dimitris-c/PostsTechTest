import Foundation

public enum GenericDisplay<T: Equatable>: Equatable {
    case loading
    case error(error: DataServiceError)
    case display(item: T)
    public typealias Item = T

    public var item: T? {
        if case let .display(loadedItem) = self {
            return loadedItem
        }
        return nil
    }
    
    public var error: Error? {
        if case let .error(error) = self {
            return error
        }
        return nil
    }
    
    public var isLoading: Bool {
        return self == .loading
    }
}
