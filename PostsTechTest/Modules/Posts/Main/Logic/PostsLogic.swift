import Foundation
import RxSwift
import RxCocoa

enum PostsLogicInput {
    case moduleReady
    case postSelection(id: Identifier<Post>)
}

enum PostsLogicEffects {
    case postDetails(id: Identifier<Post>)
}

struct PostsLogicState: LogicStateType {
    var effects: [PostsLogicEffects]
    var state: GenericState<[Post]>
}

typealias PostsLogicContext = GenericState<[Post]>
typealias PostsLogicStateUpdate = LogicStateUpdate<PostsLogicState>


protocol PostsLogicType {
    func connect(inputs: Driver<PostsLogicInput>) -> Driver<(context: PostsLogicContext, effects: [PostsLogicEffects])>
}

final class PostsLogic: PostsLogicType {
    
    private let networkingUseCase: PostsNetworkingUseCase
    
    init(networkingUseCase: PostsNetworkingUseCase) {
        self.networkingUseCase = networkingUseCase
    }
    
    func connect(inputs: Driver<PostsLogicInput>) -> Driver<(context: PostsLogicContext, effects: [PostsLogicEffects])> {
        let initial = PostsLogicState(effects: [], state: .loading)
        
        let networkingCase = self.networkingUseCase.handle(input: inputs)
        let selection = self.handle(inputs)
        
        let state = Driver.merge(networkingCase, selection)
            .scan(initial) { (state, stateUpdate) -> PostsLogicState in
                let clear = state.update(keyPath: \.effects, withValue: [])
                return stateUpdate(clear)
        }
        
        return state.map(logicStateToContext)
    }
    
    private func handle(_ inputs: Driver<PostsLogicInput>) -> Driver<PostsLogicStateUpdate> {
        return inputs.flatMap({ input -> Driver<PostsLogicStateUpdate> in
            switch input {
            case .postSelection(let id):
                let stateUpdate = simpleStateUpdate(keyPath: \PostsLogicState.effects, withValue: [.postDetails(id: id)])
                return Driver.just(stateUpdate)
            default: return .empty()
            }
        })
    }
    
    private func logicStateToContext(_ inputs: PostsLogicState) -> (context: PostsLogicContext, effects: [PostsLogicEffects]) {
        switch inputs.state {
        case .loading:
            return (context: GenericState.loading, effects: inputs.effects)
        case .loaded(let items):
            return (context: GenericState.loaded(item: items), effects: inputs.effects)
        case .error(let error):
            return (context: GenericState.error(error: error), effects: [])
        }
    }
}
