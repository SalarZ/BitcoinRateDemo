//
//  CryptoRepositoryErrorTests.swift
//  BitcoinRateDemoTests
//
//  Created by Salar on 3/7/26.
//

import Testing
import Foundation
@testable import BitcoinRateDemo

struct CryptoRepositoryErrorTests {

    @Test("noConnection has expected description")
    func noConnectionDescription() {
        let error = CryptoRepositoryError.noConnection
        #expect(error.errorDescription == String(localized: "error.no.connection"))
    }

    @Test("serverError has expected description regardless of status code")
    func serverErrorDescription() {
        let error = CryptoRepositoryError.serverError(statusCode: 503)
        #expect(error.errorDescription == String(localized: "error.server.error"))
    }

    @Test("unexpected has expected description")
    func unexpectedDescription() {
        let error = CryptoRepositoryError.unexpected
        #expect(error.errorDescription == String(localized: "error.unexpected"))
    }
}
