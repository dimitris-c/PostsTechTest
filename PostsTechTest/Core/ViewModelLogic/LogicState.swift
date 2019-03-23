import Foundation

public protocol LogicStateType {
    func update<T>(keyPath: WritableKeyPath<Self, T>, withValue: T) -> Self
    func update<T>(keyPath: WritableKeyPath<Self, T>, updatingWith: (T) -> T) -> Self
}

public extension LogicStateType {
    func update<T>(keyPath: WritableKeyPath<Self, T>, withValue value: T) -> Self {
        var newState = self
        newState[keyPath: keyPath] = value
        return newState
    }
    
    func update<T>(keyPath: WritableKeyPath<Self, T>, updatingWith updater: (T) -> T) -> Self {
        var newState = self
        newState[keyPath: keyPath] = updater(newState[keyPath: keyPath])
        return newState
    }
}

public typealias LogicStateUpdate<T> = (T) -> T

public func simpleStateUpdate<T: LogicStateType, U>(keyPath: WritableKeyPath<T, U>, withValue value: U) -> LogicStateUpdate<T> {
    return { state in
        return state.update(keyPath: keyPath, withValue: value)
    }
}

public func emptyStateUpdate<T: LogicStateType>(_ state: T) -> T {
    return state
}
