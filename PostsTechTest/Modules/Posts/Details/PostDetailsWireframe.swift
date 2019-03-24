import UIKit

final class PostDetailsWireframe {
    
    init() {
        
    }
    
    func showModule(on viewController: UINavigationController, post: Post) {
        
        let logic = PostDetailsLogic(post: post)
        let viewModel = PostDetailsViewModel(logic: logic)
        let postDetailViewController = PostDetailsViewController(viewModel: viewModel)
        
        viewController.pushViewController(postDetailViewController, animated: true)
    }
    
}
