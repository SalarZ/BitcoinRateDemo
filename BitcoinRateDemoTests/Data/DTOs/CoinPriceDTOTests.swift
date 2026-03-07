//
//  CoinPriceDTOTests.swift
//  BitcoinRateDemoTests
//
//  Created by Salar on 3/7/26.
//

import Testing
import Foundation
@testable import BitcoinRateDemo

struct CoinPriceDTOTests {

    @Test func initDecoderValidData() async throws {
        let jsonData = "{\"bitcoin\":{\"eur\":58427.92998898534,\"last_updated_at\":1772904796}}".data(using: .utf8)!
        let result = try JSONDecoder().decode(CoinGeckoPricesDTO.self, from: jsonData)
        let bitcoin = try #require(result["bitcoin"])
        #expect(bitcoin.prices == ["eur": 58427.92998898534])
        #expect(bitcoin.lastUpdatedAt == Date(timeIntervalSince1970: 1772904796))
    }

    @Test func initDecoderInvalidData() async {
        let jsonData = "{\"bitcoin\":{\"eur\":58427.92998898534}}".data(using: .utf8)!
        #expect(throws: Error.self) {
            try JSONDecoder().decode(CoinGeckoPricesDTO.self, from: jsonData)
        }
    }

    @Test func initializer() {
        let prices: [String: Double] = ["eur": 12313]
        let date = Date.now
        let coinPrice = CoinPriceDTO(prices: prices, lastUpdatedAt: date)
        #expect(coinPrice.prices == prices)
        #expect(coinPrice.lastUpdatedAt == date)
    }
}
