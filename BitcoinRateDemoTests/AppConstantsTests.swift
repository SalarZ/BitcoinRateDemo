//
//  AppConstantsTests.swift
//  BitcoinRateDemoTests
//
//  Created by Salar on 3/8/26.
//

import Testing
import Foundation
@testable import BitcoinRateDemo

struct AppConstantsTests {

    @Test("Coin constants are correct")
    func coinConstants() {
        #expect(AppConstants.Coin.bitcoinId == "bitcoin")
    }

    @Test("Currency constants are correct")
    func currencyConstants() {
        #expect(AppConstants.Currency.eur == "eur")
        #expect(AppConstants.Currency.usd == "usd")
        #expect(AppConstants.Currency.gbp == "gbp")
    }

    @Test("detailCurrencies contains expected values in order")
    func detailCurrencies() {
        #expect(AppConstants.Currency.detailCurrencies == ["eur", "usd", "gbp"])
    }

    @Test("API constants are correct")
    func apiConstants() {
        #expect(AppConstants.API.baseURL.absoluteString == "https://api.coingecko.com/api/v3/")
        #expect(AppConstants.API.priceHistoryDays == 14)
    }

    @Test("Logging subsystem is non-empty and uses bundle identifier when available")
    func loggingSubsystem() {
        let expected = Bundle.main.bundleIdentifier ?? "BitcoinTest"
        #expect(AppConstants.Logging.subsystem == expected)
        #expect(!AppConstants.Logging.subsystem.isEmpty)
    }
}
