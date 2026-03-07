//
//  MockCryptoPriceRepository.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation
@testable import BitcoinRateDemo

final class MockCryptoPriceRepository: CryptoPriceRepository {
    var historicalPricesResult: Result<[PricePoint], Error> = .success([])

    var livePriceResult: Result<LivePrice, Error> = .success(
        LivePrice(name: "bitcoin", prices: [:], lastUpdate: .now)
    )

    private(set) var historicalPricesCallCount: [(coinId: String, currency: String, days: Int)] = []
    private(set) var livePriceCallCount: [(coinId: String, currencies: [String])] = []

    func historicalPrices(coinId: String, currency: String, days: Int) async throws -> [PricePoint] {
        historicalPricesCallCount.append((coinId, currency, days))
        return try historicalPricesResult.get()
    }

    func livePrice(coinId: String, currencies: [String]) async throws -> LivePrice {
        livePriceCallCount.append((coinId, currencies))
        return try livePriceResult.get()
    }
}
