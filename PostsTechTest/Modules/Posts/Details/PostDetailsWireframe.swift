import UIKit

final class PostDetailsWireframe {
    
    init() {
        
    }
    
    func showModule(on viewController: UINavigationController, postId: Identifier<Post>) {
        
        let logic = PostDetailsLogic(postId: postId)
        let viewModel = PostDetailsViewModel(logic: logic)
        let postDetailViewController = PostDetailsViewController(viewModel: viewModel)
        
        viewController.pushViewController(postDetailViewController, animated: true)
    }
    
}
