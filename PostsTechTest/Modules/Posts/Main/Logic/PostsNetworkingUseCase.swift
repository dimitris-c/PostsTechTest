import Foundation
import RxSwift
import RxCocoa

struct PostsNetworkingUseCase {
    
    private let apiClient: PostsNetworking
    
    init(apiClient: PostsNetworking) {
        self.apiClient = apiClient
    }
    
    func handle(input: Driver<PostsLogicInput>) -> Driver<LogicStateUpdate<PostsLogicState>> {
        return input.flatMapLatest({ (input) -> Driver<LogicStateUpdate<PostsLogicState>> in
            switch input {
            case .moduleReady:
                return self.apiClient.getPosts()
                    .map(self.stateUpdate)
                    .asDriver(onErrorRecover: self.recoverFromError)
            }
        })
    }
    
    private func stateUpdate(_ data: [Post]) -> LogicStateUpdate<PostsLogicState> {
        return { state in
            state.update(keyPath: \.state, withValue: .loaded(item: data))
        }
    }
    
    private func errorStateUpdate(_ error: Error) -> LogicStateUpdate<PostsLogicState> {
        return { state in
            state.update(keyPath: \.state, withValue: .error(error: .networking(error)))
        }
    }
    
    private func recoverFromError(_ error: Error) -> Driver<LogicStateUpdate<PostsLogicState>> {
        return .just(self.errorStateUpdate(error))
    }
    
}
