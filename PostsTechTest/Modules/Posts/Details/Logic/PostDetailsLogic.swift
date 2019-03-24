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
    private let post: Post
    private let apiClient: PostsNetworking
    private let persistance: PostsPersistanceType
    
    init(post: Post, apiClient: PostsNetworking, persistance: PostsPersistanceType) {
        self.post = post
        self.apiClient = apiClient
        self.persistance = persistance
    }
    
    func connect(inputs: Driver<PostDetailsLogicInput>) -> Driver<PostDetailsOutput> {
        let initial = PostDetailsLogicState(effects: [], state: .loading)
        
        let state = self.handle(inputs)
            .startWith(simpleStateUpdate(keyPath: \.state, withValue: .loading))
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
                let dataFromStorage = self.getDataFromStorage() ?? ([], [])
                return Observable.zip(self.apiClient.getUsers(), self.apiClient.getComments(postId: self.post.id))
                    .startWith(dataFromStorage)
                    .do(onNext: self.saveDataToStorage)
                    .flatMapLatest({ (users, comments) -> Observable<PostDetailData> in
                        guard let data = self.dataToDetailData(users, comments: comments) else {
                             return .empty()
                        }
                        return .just(data)
                    })
                    .map({ (data) -> PostDetailsLogicStateUpdate in
                        return simpleStateUpdate(keyPath: \.state, withValue: .loaded(item: data))
                    })
                    .asDriver(onErrorRecover: self.recoverFromError)
            }
        })
    }
    
    private func dataToDetailData(_ users: [User], comments: [Comment]) -> PostDetailData? {
        guard let userForPost = users.first(where: { $0.id == self.post.userId }) else {
            return nil
        }
        let totalComments = comments.count
        return PostDetailData(post: self.post, user: userForPost, totalComments: totalComments)
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
    
    private func recoverFromError(_ error: Error) -> Driver<PostDetailsLogicStateUpdate> {
        if let data = self.getDataFromStorage(),
            let detailData = dataToDetailData(data.users, comments: data.comments) {
            return .just(simpleStateUpdate(keyPath: \PostDetailsLogicState.state,
                                           withValue: GenericState.loaded(item: detailData)))
        }
        return .just(simpleStateUpdate(keyPath: \PostDetailsLogicState.state,
                                       withValue: .error(error: .networking(error))))
    }
    
    private func getDataFromStorage() -> (users: [User], comments: [Comment])? {
        guard let users = self.persistance.getUsers(),
            let comments = self.persistance.getComments(postId: self.post.id) else {
                return nil
        }
        return (users, comments)
    }
    
    private func saveDataToStorage(_ users: [User], _ comments: [Comment]) {
        self.persistance.saveUsers(users: users)
        self.persistance.saveComments(for: self.post.id, comments: comments)
    }
    
}
