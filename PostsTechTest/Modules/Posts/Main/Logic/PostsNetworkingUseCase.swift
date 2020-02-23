import Foundation
import RxSwift
import RxCocoa

struct PostsNetworkingUseCase {
    
    private let apiClient: PostsNetworking
    private let persistance: PostsPersistanceType
    
    init(apiClient: PostsNetworking, persistance: PostsPersistanceType) {
        self.apiClient = apiClient
        self.persistance = persistance
    }
    
    func handle(input: Driver<PostsLogicInput>) -> Driver<LogicStateUpdate<PostsLogicState>> {
        return input.flatMapLatest({ (input) -> Driver<LogicStateUpdate<PostsLogicState>> in
            switch input {
            case .moduleReady:
                let fetchedPosts = self.persistance.getPosts() ?? []
                return self.apiClient.getPosts()
                    .do(onNext: self.persistance.savePosts)
                    .startWith(fetchedPosts)
                    .map(self.stateUpdate)
                    .asDriver(onErrorRecover: self.recoverFromError)
            default: return .empty()
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
        if let posts = self.persistance.getPosts() {
            return .just(self.stateUpdate(posts))
        }
        return .just(self.errorStateUpdate(error))
    }
    
}
