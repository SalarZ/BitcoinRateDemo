//
//  DefaultNetworkClientTests.swift
//  BitcoinRateDemoTests
//
//  Created by Salar on 3/8/26.
//

import Testing
import Foundation
@testable import BitcoinRateDemo

struct DefaultNetworkClientTests {

    @Test
    func sendCreateValidRequest() async throws {
        let request = APIRequest(
            path: "path/test",
            method: .get,
            queryItems: [
                .init(name: "param1", value: "value1")
            ],
            headers: ["header": "value"],
            requiresAuthorization: false)
        let client = MockHTTPClient(response: .success(makeResponse()))
        let baseURL = URL(string: "http://baseURL.com")!
        let sut = DefaultNetworkClient(httpClient: client, baseURL: baseURL)

        let _: Data? = try? await sut.send(request)

        #expect(client.dataCalls.count == 1)
        let apiRequest = try #require(client.dataCalls.first)
        #expect(apiRequest.httpMethod == request.method.rawValue)
        request.headers.forEach { headerItem in
            #expect(apiRequest.allHTTPHeaderFields?.contains(where: { $0.key == headerItem.key && $0.value == headerItem.value}) ?? false)
        }

        let apiRequestURL = try #require(apiRequest.url)
        let requestURLComponent = URLComponents(url: apiRequestURL, resolvingAgainstBaseURL: false)
        #expect(requestURLComponent?.scheme == "http")
        #expect(requestURLComponent?.host == "baseURL.com")
        #expect(requestURLComponent?.path == "/\(request.path)")

        let queryItems = try #require(requestURLComponent?.queryItems)
        #expect(queryItems == request.queryItems)
    }

    @Test("send sets httpMethod correctly", arguments: [HTTPMethod.get, .delete, .post, .put])
    func sendCreateValidRequestWithHTTPMethod(httpMethod: HTTPMethod) async throws {
        let request = APIRequest(
            path: "path/test",
            method: httpMethod)
        let client = MockHTTPClient(response: .success(makeResponse()))
        let baseURL = URL(string: "http://baseURL.com")!
        let sut = DefaultNetworkClient(httpClient: client, baseURL: baseURL)

        let _: Data? = try? await sut.send(request)

        #expect(client.dataCalls.count == 1)
        let apiRequest = try #require(client.dataCalls.first)
        #expect(apiRequest.httpMethod == request.method.rawValue)
    }

    @Test
    func sendCallsAuthorize_whenRequiresAuthorizationIsTrue() async throws {
        let authorizer = MockRequestAuthorizer()
        let request = APIRequest(path: "path/test", method: .get, requiresAuthorization: true)
        let client = MockHTTPClient(response: .success(makeResponse()))
        let baseURL = URL(string: "http://baseURL.com")!
        let sut = DefaultNetworkClient(httpClient: client, baseURL: baseURL, requestAuthorizer: authorizer)

        let _: Data? = try? await sut.send(request)

        #expect(authorizer.authorizeCallsCount == 1)
    }

    @Test
    func sendDoesNotCallsAuthorize_whenRequiresAuthorizationIsFalse() async throws {
        let authorizer = MockRequestAuthorizer()
        let request = APIRequest(path: "path/test", method: .get, requiresAuthorization: false)
        let client = MockHTTPClient(response: .success(makeResponse()))
        let baseURL = URL(string: "http://baseURL.com")!
        let sut = DefaultNetworkClient(httpClient: client, baseURL: baseURL, requestAuthorizer: authorizer)

        let _: Data? = try? await sut.send(request)

        #expect(authorizer.authorizeCallsCount == 0)
    }

    @Test
    func sendCallsValidator() async throws {
        let validator = MockResponseValidator()
        let request = APIRequest(path: "path/test", method: .get, requiresAuthorization: false)
        let client = MockHTTPClient(response: .success(makeResponse()))
        let baseURL = URL(string: "http://baseURL.com")!
        let sut = DefaultNetworkClient(httpClient: client, baseURL: baseURL, responseValidator: validator)

        let _: Data? = try? await sut.send(request)

        #expect(validator.validateCallsCount == 1)
    }

    @Test
    func sendThrowsAnErrorOnInvalidResponseData() async throws {
        let request = APIRequest(path: "path/test", method: .get, requiresAuthorization: false)
        let client = MockHTTPClient(response: .success(makeResponse()))
        let baseURL = URL(string: "http://baseURL.com")!
        let sut = DefaultNetworkClient(httpClient: client, baseURL: baseURL)

        await #expect(throws: Error.self) {
            let _: Data = try await sut.send(request)
        }
    }

    @Test
    func sendRetursValidObjectOnSuccess() async throws {
        let responseObject = MockModel(id: 1, name: "test")
        let responseData = try JSONEncoder().encode(responseObject)
        let request = APIRequest(path: "path/test", method: .get, requiresAuthorization: false)
        let client = MockHTTPClient(response: .success(makeResponse(data: responseData)))
        let baseURL = URL(string: "http://baseURL.com")!
        let sut = DefaultNetworkClient(httpClient: client, baseURL: baseURL)

        let result: MockModel = try await sut.send(request)

        #expect(result == responseObject)

    }

    // MARK: Helpers
    private func makeResponse(statusCode: Int = 200, data: Data = Data("data".utf8)) -> (Data, URLResponse) {
        let urlResponse = HTTPURLResponse(url: URL(string: "http://any-url")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        return (data, urlResponse)
    }
}

private struct MockModel: Codable, Equatable {
    let id: Int
    let name: String
}

private final class MockHTTPClient: HTTPClient {
    typealias Response = (Data, URLResponse)
    private let response: Result<Response, Error>
    var dataCalls: [URLRequest] = []

    init(response: Result<Response, Error>) {
        self.response = response
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        dataCalls.append(request)
        return try response.get()
    }
}

private final class MockRequestAuthorizer: RequestAuthorizer {
    private(set) var authorizeCallsCount = 0
    func authorize(_ request: inout URLRequest) {
        authorizeCallsCount += 1
    }
}

private final class MockResponseValidator: ResponseValidator {
    private(set) var validateCallsCount = 0
    func validate(data: Data, response: URLResponse) throws {
        validateCallsCount += 1
    }
}
