//
//  APIKeyAuthorizerTests.swift
//  BitcoinRateDemoTests
//
//  Created by Salar on 3/7/26.
//

import Testing
import Foundation
@testable import BitcoinRateDemo

struct APIKeyAuthorizerTests {

    @Test func authorizeSetsApiKeyToHeader() async throws {
        let apiKey = "any-key"
        let sut = APIKeyAuthorizer(apiKey: apiKey)
        var request = URLRequest(url: URL(string: "any-url.com")!)
        sut.authorize(&request)

        #expect(request.allHTTPHeaderFields?["x-cg-demo-api-key"] == apiKey)
    }

}
