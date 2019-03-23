import UIKit

final class PostsWireframe {
    
    init() {
        
    }
    
    func prepareModule() -> UINavigationController {
        
        let apiClient = PostsNetworkingService(networking: NetworkingClient(), baseURL: APIConfig.staging.baseURL!)
        let persistance = PostsPersistance(persistance: PersistanceService())
        let networkingCase = PostsNetworkingUseCase(apiClient: apiClient, persistance: persistance)
        
        let logic = PostsLogic(networkingUseCase: networkingCase)
        let viewModel = PostsViewModel(logic: logic)
        let viewController = PostsViewController(viewModel: viewModel)
        
        return UINavigationController(rootViewController: viewController)
    }
}
