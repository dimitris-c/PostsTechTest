import UIKit

enum PostsFlowRoute {
    case postDetails(postId: Identifier<Post>)
}

protocol PostsFlowNavigable: class {
    func handle(_ route: PostsFlowRoute)
}

final class PostsWireframe {
    
    private var navigationController: UINavigationController?
    
    init() {
        
    }
    
    func prepareModule() -> UINavigationController {
        
        let apiClient = PostsNetworkingService(networking: NetworkingClient(), baseURL: APIConfig.staging.baseURL!)
        let persistance = PostsPersistance(persistance: PersistanceService())
        let networkingCase = PostsNetworkingUseCase(apiClient: apiClient, persistance: persistance)
        
        let logic = PostsLogic(networkingUseCase: networkingCase)
        let viewModel = PostsViewModel(logic: logic, navigable: self)
        let viewController = PostsViewController(viewModel: viewModel)
        
        let navigationController = UINavigationController(rootViewController: viewController)
        self.navigationController = navigationController
        
        return navigationController
    }
    
    private func showDetail(postId: Identifier<Post>) {
        guard let navigationController = self.navigationController else { return }
        let wireframe = PostDetailsWireframe()
        wireframe.showModule(on: navigationController, postId: postId)
    }
}

extension PostsWireframe: PostsFlowNavigable {
    func handle(_ route: PostsFlowRoute) {
        switch route {
        case .postDetails(let id):
            self.showDetail(postId: id)
            return
        }
    }
}

