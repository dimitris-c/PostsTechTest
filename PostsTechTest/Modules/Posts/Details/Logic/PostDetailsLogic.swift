import Foundation
import RxSwift
import RxCocoa

enum PostDetailsLogicInput {
    case moduleReady
}

enum PostDetailsLogicEffects {
    case none
}

struct PostDetailData: Equatable {
    let post: Post
    let user: User
    let totalComments: Int
}

struct PostDetailsLogicState: LogicStateType {
    var effects: [PostDetailsLogicEffects]
    var state: GenericState<PostDetailData>
}

typealias PostDetailsLogicContext = GenericState<PostDetailData>
typealias PostDetailsLogicStateUpdate = LogicStateUpdate<PostDetailsLogicState>
typealias PostDetailsOutput = (context: PostDetailsLogicContext, effects: [PostDetailsLogicEffects])

protocol PostDetailsLogicType {
    func connect(inputs: Driver<PostDetailsLogicInput>) -> Driver<PostDetailsOutput>
}

final class PostDetailsLogic: PostDetailsLogicType {
    private let postId: Identifier<Post>
    
    init(postId: Identifier<Post>) {
        self.postId = postId
    }
    
    func connect(inputs: Driver<PostDetailsLogicInput>) -> Driver<PostDetailsOutput> {
        let initial = PostDetailsLogicState(effects: [], state: .loading)
        
        let state = self.handle(inputs)
            .scan(initial) { (state, stateUpdate) -> PostDetailsLogicState in
                let clear = state.update(keyPath: \.effects, withValue: [])
                return stateUpdate(clear)
        }
        
        return state.map(logicStateToContext)
    }
    
    
    private func handle(_ inputs: Driver<PostDetailsLogicInput>) -> Driver<PostDetailsLogicStateUpdate> {
        return inputs.flatMap({ input -> Driver<PostDetailsLogicStateUpdate> in
            switch input {
            case .moduleReady:
                let state = simpleStateUpdate(keyPath: \PostDetailsLogicState.effects, withValue: [])
                return Driver.just(state)
            }
        })
    }

    private func logicStateToContext(_ inputs: PostDetailsLogicState) -> PostDetailsOutput {
        switch inputs.state {
        case .loading:
            return (context: GenericState.loading, effects: inputs.effects)
        case .loaded(let item):
            return (context: GenericState.loaded(item: item), effects: inputs.effects)
        case .error(let error):
            return (context: GenericState.error(error: error), effects: [])
        }
    }
}
