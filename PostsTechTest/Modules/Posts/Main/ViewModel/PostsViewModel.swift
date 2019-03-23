import Foundation
import RxSwift
import RxCocoa

enum PostsDisplayInput {
    case moduleLoaded
    case postSelected(id: Identifier<Post>)
}

struct PostDisplayItem: Equatable {
    let title: String
    let id: Identifier<Post>
    
    init(with post: Post) {
        self.title = post.title
        self.id = post.id
    }
}

struct PostItem: Equatable {
    let navigationTitle: String
    let posts: [PostDisplayItem]
}

protocol PostsViewModelType {
    func connect(_ inputs: Driver<PostsDisplayInput>) -> Driver<GenericDisplay<PostItem>>
}

final class PostsViewModel: PostsViewModelType {
    private let logic: PostsLogicType
    private let navigable: PostsFlowNavigable
    
    init(logic: PostsLogicType, navigable: PostsFlowNavigable) {
        self.logic = logic
        self.navigable = navigable
    }
    
    func connect(_ inputs: Driver<PostsDisplayInput>) -> Driver<GenericDisplay<PostItem>> {
        let logic = self.logic.connect(inputs: inputs.map(displayToLogicInput))
        
        let context = logic
            .map { $0.context }
            .map(stateToDisplay)
        
        let effects = logic
            .map { $0.effects }
            .map(handleEffects)
            .flatMapLatest { _ -> Driver<GenericDisplay<PostItem>> in .empty() }
        
        return Driver.merge(context, effects)
    }
    
    func displayToLogicInput(_ inputs: PostsDisplayInput) -> PostsLogicInput {
        switch inputs {
        case .moduleLoaded: return .moduleReady
        case .postSelected(let id): return .postSelection(id: id)
        }
    }
    
    func stateToDisplay(_ inputs: GenericState<[Post]>) -> GenericDisplay<PostItem> {
        switch inputs {
        case .loading:
            return GenericDisplay.loading
        case .loaded(let item):
            let decoratedItems = item.map(PostDisplayItem.init(with:))
            return GenericDisplay.display(item: PostItem(navigationTitle: "Posts", posts: decoratedItems))
        case .error(let error):
            return GenericDisplay.error(error: error)
        }
    }
    
    func handleEffects(_ effects: [PostsLogicEffects]) {
        effects.forEach { (effect) in
            switch effect {
            case .postDetails(let id):
                self.navigable.handle(PostsFlowRoute.postDetails(postId: id))
                break
            }
        }
    }
    
    deinit {
        print("ASDFADSFADS")
    }
}

