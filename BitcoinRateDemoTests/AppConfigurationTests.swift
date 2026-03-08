//
//  AppConfigurationTests.swift
//  BitcoinRateDemoTests
//
//  Created by Salar on 3/8/26.
//

import Testing
import Foundation
@testable import BitcoinRateDemo

struct AppConfigurationTests {

    @Test
    func keys() {
        #expect(AppConfiguration.Keys.apiKey == "COINGECKO_API_KEY")
    }

    @Test
    func coinGeckoAPIKey() throws {
        let accessTokenObject = Bundle.main.object(forInfoDictionaryKey: AppConfiguration.Keys.apiKey)
        let expectedAccessToken = try #require(accessTokenObject as? String)

        let accessToken = AppConfiguration.coinGeckoAPIKey

        #expect(accessToken == expectedAccessToken)
    }
}
