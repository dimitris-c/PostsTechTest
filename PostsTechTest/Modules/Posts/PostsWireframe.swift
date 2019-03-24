import UIKit

enum PostsFlowRoute {
    case postDetails(post: Post)
}

protocol PostsFlowNavigable: class {
    func handle(_ route: PostsFlowRoute)
}

final class PostsWireframe {
    
    private var navigationController: UINavigationController?
    
    private lazy var apiClient: PostsNetworking = {
      return PostsNetworkingService(networking: NetworkingClient(), baseURL: APIConfig.staging.baseURL!)
    }()
    
    private lazy var postsPeristance: PostsPersistance = {
        return PostsPersistance(persistance: PersistanceService())
    }()
    
    init() {
        
    }
    
    func prepareModule() -> UINavigationController {
        
        let networkingCase = PostsNetworkingUseCase(apiClient: self.apiClient, persistance: self.postsPeristance)
        
        let logic = PostsLogic(networkingUseCase: networkingCase)
        let viewModel = PostsViewModel(logic: logic, navigable: self)
        let viewController = PostsViewController(viewModel: viewModel)
        
        let navigationController = UINavigationController(rootViewController: viewController)
        self.navigationController = navigationController
        
        return navigationController
    }
    
    private func showDetail(post: Post) {
        guard let navigationController = self.navigationController else { return }
        let wireframe = PostDetailsWireframe(apiClient: self.apiClient, persistance: self.postsPeristance)
        wireframe.showModule(on: navigationController, post: post)
    }
}

extension PostsWireframe: PostsFlowNavigable {
    func handle(_ route: PostsFlowRoute) {
        switch route {
        case .postDetails(let post):
            self.showDetail(post: post)
            return
        }
    }
}

