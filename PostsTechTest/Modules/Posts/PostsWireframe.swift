import UIKit

final class PostsWireframe {
    
    init() {
        
    }
    
    func prepareModule() -> UINavigationController {
        
        let logic = PostsLogic()
        let viewModel = PostsViewModel(logic: logic)
        let viewController = PostsViewController(viewModel: viewModel)
        
        return UINavigationController(rootViewController: viewController)
    }
}
