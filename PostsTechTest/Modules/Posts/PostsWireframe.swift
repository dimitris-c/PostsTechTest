import UIKit

final class PostsWireframe {
    
    init() {
        
    }
    
    func prepareModule() -> UINavigationController {
        
        let apiClient = PostsNetworkingService(networking: NetworkingClient(), baseURL: APIConfig.staging.baseURL!)
        let networkingCase = PostsNetworkingUseCase(apiClient: apiClient)
        
        let logic = PostsLogic(networkingUseCase: networkingCase)
        let viewModel = PostsViewModel(logic: logic)
        let viewController = PostsViewController(viewModel: viewModel)
        
        return UINavigationController(rootViewController: viewController)
    }
}
