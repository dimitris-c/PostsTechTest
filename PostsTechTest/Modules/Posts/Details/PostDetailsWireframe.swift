import UIKit

final class PostDetailsWireframe {
    
    private let apiClient: PostsNetworking
    private let persistance: PostsPersistance
    
    init(apiClient: PostsNetworking, persistance: PostsPersistance) {
        self.apiClient = apiClient
        self.persistance = persistance
    }
    func showModule(on viewController: UINavigationController, post: Post) {
        
        let logic = PostDetailsLogic(post: post, apiClient: self.apiClient, persistance: self.persistance)
        let viewModel = PostDetailsViewModel(logic: logic)
        let postDetailViewController = PostDetailsViewController(viewModel: viewModel)
        
        viewController.pushViewController(postDetailViewController, animated: true)
    }
    
}
