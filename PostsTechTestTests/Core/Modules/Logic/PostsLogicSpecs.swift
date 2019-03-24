import XCTest
import Quick
import Nimble
import RxSwift
import RxCocoa
import RxBlocking

@testable import PostsTechTest

class PostsLogicSpecs: QuickSpec {

    override func spec() {
        describe("Using PostsLogic") {
            var mockNetworking: MockPostsNetworking!
            var mockPersistance: MockPostsPersistance!
            var useCase: PostsNetworkingUseCase!
            var sut: PostsLogic!

            beforeEach {
                mockNetworking = MockPostsNetworking()
                mockPersistance = MockPostsPersistance()
                
                useCase = PostsNetworkingUseCase(apiClient: mockNetworking, persistance: mockPersistance)
                sut = PostsLogic(networkingUseCase: useCase)
            }
            
            context("when module is ready") {
                var outputs: [(context: PostsLogicContext, effects: [PostsLogicEffects])] = []
                let post = Post(userId: 1, id: 2, title: "a title", body: "some body")
                let posts = [post]
                context("without any data from storage") {
                    beforeEach {
                        mockNetworking.posts = .just(posts)
                        mockPersistance.posts = nil
                        outputs = try! sut.connect(inputs: .just(.moduleReady)).toBlocking().toArray()
                    }
                    
                    it("should have correct outputs") {
                        let expectedOutputs = [
                            PostsLogicContext.loading,
                            PostsLogicContext.loaded(item: []),
                            PostsLogicContext.loaded(item: posts)
                        ]
                        let context = outputs.map { $0.context }
                        expect(context).to(equal(expectedOutputs))
                    }
                    
                    it("should store data to storage") {
                        expect(mockPersistance.savePostsSpy.called).to(beTrue())
                        expect(mockPersistance.savePostsSpy.posts).to(equal(posts))
                    }
                }
                
                context("with data from storage") {
                    beforeEach {
                        mockNetworking.posts = .just(posts)
                        mockPersistance.posts = posts
                        outputs = try! sut.connect(inputs: .just(.moduleReady)).toBlocking().toArray()
                    }
                    
                    it("it should have correct outputs") {
                        let expectedOutputs = [
                            PostsLogicContext.loading,
                            PostsLogicContext.loaded(item: posts),
                            PostsLogicContext.loaded(item: posts)
                        ]
                        let context = outputs.map { $0.context }
                        expect(context).to(equal(expectedOutputs))
                    }
                }
                
                context("with no data from storage and a network error") {
                    beforeEach {
                        mockNetworking.posts = Observable<[Post]>.error(MockError.generic)
                        mockPersistance.posts = nil
                        outputs = try! sut.connect(inputs: .just(.moduleReady)).toBlocking().toArray()
                    }
                    
                    it("it should have correct outputs") {
                        let expectedOutputs = [
                            PostsLogicContext.loading,
                            PostsLogicContext.loaded(item: []),
                            PostsLogicContext.error(error: DataServiceError.networking(MockError.generic))
                        ]
                        let context = outputs.map { $0.context }
                        expect(context).to(equal(expectedOutputs))
                    }
                }
                
                context("with data from storage and a network error") {
                    beforeEach {
                        mockNetworking.posts = Observable<[Post]>.error(MockError.generic)
                        mockPersistance.posts = posts
                        outputs = try! sut.connect(inputs: .just(.moduleReady)).toBlocking().toArray()
                    }
                    
                    it("it should have correct outputs") {
                        let expectedOutputs = [
                            PostsLogicContext.loading,
                            PostsLogicContext.loaded(item: posts),
                            PostsLogicContext.loaded(item: posts)
                        ]
                        let context = outputs.map { $0.context }
                        expect(context).to(equal(expectedOutputs))
                    }
                }
                
                context("on post selection") {
                    beforeEach {
                        mockNetworking.posts = .just(posts)
                        mockPersistance.posts = nil
                        let inputs = Driver<PostsLogicInput>.of(.moduleReady, .postSelection(id: 2))
                        outputs = try! sut.connect(inputs: inputs).toBlocking().toArray()
                    }
                    
                    it("it should have correct outputs") {
                        let expectedEffects = [PostsLogicEffects.postDetails(post: post)]
                        let effects = outputs.map { $0.effects }.last
                        
                        expect(effects).to(equal(expectedEffects))
                    }
                }
            }
        }
    }

}
