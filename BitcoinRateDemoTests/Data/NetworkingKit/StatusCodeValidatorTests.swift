//
//  StatusCodeValidatorTests.swift
//  BitcoinRateDemoTests
//
//  Created by Salar on 3/7/26.
//

import Testing
import Foundation
@testable import BitcoinRateDemo

struct StatusCodeValidatorTests {

    private let sut = StatusCodeValidator()
    private let anyData = Data()
    private let anyURL = URL(string: "https://example.com")!

    @Test("does not throw for valid status code", arguments: [200, 210,290,299])
    func passesForValidRange200(statusCode: Int) async throws {
        try sut.validate(data: anyData, response: httpResponse(statusCode: statusCode))
    }

    @Test("throws serverError for invalid status code", arguments: [100,300,400,500])
    func throwsForInvalidStatusCode(statusCode: Int) throws {
        #expect(throws: CryptoRepositoryError.serverError(statusCode: statusCode)) {
            try sut.validate(data: anyData, response: httpResponse(statusCode: statusCode))
        }
    }

    // MARK: - Helpers
    private func httpResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
