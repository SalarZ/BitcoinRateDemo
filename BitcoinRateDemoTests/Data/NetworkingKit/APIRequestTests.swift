//
//  APIRequestTests.swift
//  BitcoinRateDemoTests
//
//  Created by Salar on 3/7/26.
//

import Testing
import Foundation
@testable import BitcoinRateDemo

struct APIRequestTests {

    @Test
    func initializer() {
        let path = "any-path"
        let queryItems: [URLQueryItem] = [
            .init(name: "param1", value: "1"),
            .init(name: "param2", value: "2")
        ]
        let headers = ["header1": "value1"]
        let sut = APIRequest(path: path,
                             queryItems: queryItems,
                             headers: headers)

        #expect(sut.path == path)
        #expect(sut.queryItems == queryItems)
        #expect(sut.headers == headers)
    }

    @Test("method sets correctly", arguments: [HTTPMethod.get, .delete, .post, .put])
    func initializerWithMethods(method: HTTPMethod) {
        let path = "any-path"
        let sut = APIRequest(path: path, method: method)

        #expect(sut.method == method)
    }

    @Test("requiresAuthorization sets correctly", arguments: [true, false])
    func initializerWithRequiresAuthorization(requiresAuthorization: Bool) {
        let path = "any-path"
        let sut = APIRequest(path: path, requiresAuthorization: requiresAuthorization)

        #expect(sut.requiresAuthorization == requiresAuthorization)
    }
}
