import Foundation
import RxSwift
import RxCocoa

enum PostDetailsDisplayInput {
    case moduleLoaded
}

struct PostDetailsDisplayItem: Equatable {
    let title: String
    let body: String
    let author: String
    let totalCommentsTitle: String
    
    init(from data: PostDetailData) {
        self.title = data.post.title
        self.body = data.post.body
        self.author = "By: \(data.user.name)"
        self.totalCommentsTitle = "Total Comments: \(data.totalComments)"
    }
}

struct PostDetailsItem: Equatable {
    let navigationTitle: String
    let item: PostDetailsDisplayItem
}

protocol PostDetailsViewModelType {
    func connect(_ inputs: Driver<PostDetailsDisplayInput>) -> Driver<GenericDisplay<PostDetailsItem>>
}

final class PostDetailsViewModel: PostDetailsViewModelType {
    private let logic: PostDetailsLogicType
    
    init(logic: PostDetailsLogicType) {
        self.logic = logic
    }
    
    func connect(_ inputs: Driver<PostDetailsDisplayInput>) -> Driver<GenericDisplay<PostDetailsItem>> {
        let logic = self.logic.connect(inputs: inputs.map(displayToLogicInput))
        
        let context = logic
            .map { $0.context }
            .map(stateToDisplay)
        
        let effects = logic
            .map { $0.effects }
            .map(handleEffects)
            .flatMapLatest { _ -> Driver<GenericDisplay<PostDetailsItem>> in .empty() }
        
        return Driver.merge(context, effects)
    }
    
    func displayToLogicInput(_ inputs: PostDetailsDisplayInput) -> PostDetailsLogicInput {
        switch inputs {
        case .moduleLoaded: return .moduleReady
        }
    }
    
    func stateToDisplay(_ inputs: GenericState<PostDetailData>) -> GenericDisplay<PostDetailsItem> {
        switch inputs {
        case .loading:
            return GenericDisplay.loading
        case .loaded(let item):
            let displayItem = PostDetailsDisplayItem(from: item)
            let postDetailsItem = PostDetailsItem(navigationTitle: item.post.title, item: displayItem)
            return GenericDisplay.display(item: postDetailsItem)
        case .error(let error):
            return GenericDisplay.error(error: error)
        }
    }
    
    func handleEffects(_ effects: [PostDetailsLogicEffects]) {
        effects.forEach { (effect) in
            switch effect {
            case .none:
                break
            }
        }
    }
}
