import XCTest
import Quick
import Nimble
import RxSwift
import RxCocoa
import RxBlocking

@testable import PostsTechTest

class NetworkingSpecs: QuickSpec {

    let url = URL(string: "http://mobile.staging.decimal.gr/api")!
    
    fileprivate func requestToSingle(sut: Networking?) -> (response: HTTPURLResponse, result: TestObject)?? {
        let endpoint = Endpoint<TestObject>(path: "some_path")
        let singleResult: Single<(response: HTTPURLResponse, result: TestObject)>? = sut?.request(endpoint, baseURL: url)
        return try? singleResult?.toBlocking().single()
    }
    
    fileprivate func requestToObservable(sut: Networking?) -> [(response: HTTPURLResponse, result: TestObject)]?? {
        let endpoint = Endpoint<TestObject>(path: "some_path")
        let observableResult: Observable<(response: HTTPURLResponse, result: TestObject)>? = sut?.request(endpoint, baseURL: url)
        return try? observableResult?.toBlocking().toArray()
    }
    
    
    override func spec() {
        describe("Using ApiClient") {
            var sut: Networking?
            var sessionMock: MockNetworkingSession!
            var response: HTTPURLResponse!
            
            describe("when the json is valid and all the keys are present") {
                beforeEach {
                    response = HTTPURLResponse(url: self.url, statusCode: 200, httpVersion: nil, headerFields: nil)!
                    let data = MockData.validJSONData
                    
                    sessionMock = MockNetworkingSession(response: response, data: data)
                    sut = NetworkingClient(session: sessionMock)
                }
                
                afterEach {
                    response = nil
                }
                
                describe("when we fetch a single result", closure: {
                    var result: (response: HTTPURLResponse, result: TestObject)??
                    
                    beforeEach {
                        result = self.requestToSingle(sut: sut)
                    }
                    
                    it("emits a single success containing the response and the decoded data") {
                        if let result = result {
                            expect(result?.response).to(equal(response))
                            expect(result?.result.title).to(equal("Test object title"))
                        } else {
                            fail("Should be success")
                        }
                    }
                })
                
                describe("when we fetch an observable result") {
                    var result: [(response: HTTPURLResponse, result: TestObject)]??
                    
                    beforeEach {
                        result = self.requestToObservable(sut: sut)
                    }
                    
                    it("emits a single success containing the response and the decoded data") {
                        if let result = result {
                            expect(result?[0].response).to(equal(response))
                            expect(result?[0].result.title).to(equal("Test object title"))
                        } else {
                            fail("Should be success")
                        }
                    }
                }
            }
            
            describe("when the json is malformed") {
                beforeEach {
                    response = HTTPURLResponse(url: self.url, statusCode: 200, httpVersion: nil, headerFields: nil)!
                    let data = MockData.invalidJSONData
                    
                    sessionMock = MockNetworkingSession(response: response, data: data)
                    sut = NetworkingClient(session: sessionMock)
                }
                
                afterEach {
                    response = nil
                }
                
                describe("when we fetch a single result", closure: {
                    var result: (response: HTTPURLResponse, result: TestObject)??
                    
                    beforeEach {
                        result = self.requestToSingle(sut: sut)
                    }
                    
                    it("fails") {
                        expect(result).to(beNil())
                    }
                })
                
                describe("when we fetch an observable result") {
                    var result: [(response: HTTPURLResponse, result: TestObject)]??
                    
                    beforeEach {
                        result = self.requestToObservable(sut: sut)
                    }
                    
                    it("fails") {
                        expect(result).to(beNil())
                    }
                }
            }
            
            describe("when a key is missing from the json response") {
                beforeEach {
                    response = HTTPURLResponse(url: self.url, statusCode: 200, httpVersion: nil, headerFields: nil)!
                    let data = MockData.invalidJSONData
                    
                    sessionMock = MockNetworkingSession(response: response, data: data)
                    sut = NetworkingClient(session: sessionMock)
                }
                
                afterEach {
                    response = nil
                }
                
                describe("when we fetch a single result", closure: {
                    var result: (response: HTTPURLResponse, result: TestObject)??
                    
                    beforeEach {
                        result = self.requestToSingle(sut: sut)
                    }
                    
                    it("fails") {
                        expect(result).to(beNil())
                    }
                })
                
                describe("when we fetch an observable result") {
                    var result: [(response: HTTPURLResponse, result: TestObject)]??
                    
                    beforeEach {
                        result = self.requestToObservable(sut: sut)
                    }
                    
                    it("fails") {
                        expect(result).to(beNil())
                    }
                }
            }
        }
    }
}

private struct MockData {
    static var invalidJSONData: Data {
        return ".".data(using: .utf8)!
    }
    
    static var missingKey: Data {
        return "{}".data(using: .utf8)!
    }
    
    static var validJSONData: Data {
        return "{\"title\": \"Test object title\" }".data(using: .utf8)!
    }
}

private struct TestObject: Codable {
    let title: String
}

class MockNetworkingSession: NetworkingSession {
    private var response: HTTPURLResponse
    private var data: Data
    
    public init(response: HTTPURLResponse, data: Data) {
        self.response = response
        self.data = data
    }
    
    func response(request: URLRequest) -> Observable<(response: HTTPURLResponse, data: Data)> {
        return .just((response, data))
    }
}
