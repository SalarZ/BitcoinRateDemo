//
//  MockCryptoPriceRepository.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation
@testable import BitcoinRateDemo

final class MockCryptoPriceRepository: CryptoPriceRepository {
    var historicalPricesResult: Result<[CryptoPrice], Error> = .success([])

    var livePriceResult: Result<LivePrice, Error> = .success(
        LivePrice(name: "bitcoin", prices: [:], lastUpdate: .now)
    )
    var priceDetailsResult: Result<PriceDetails, Error> = .success(
        PriceDetails(name: "bitcoin", eurPrice: 1_000, usdPrice: 1_200, gbpPrice: 800, lastUpdate: Date.now)
    )

    private(set) var historicalPricesCalls: [(coinId: String, currency: String, days: Int)] = []
    private(set) var livePriceCalls: [(coinId: String, currencies: [String])] = []
    private(set) var priceDetailsCalls: [(coinId: String, date: Date)] = []


    func historicalPrices(coinId: String, currency: String, days: Int) async throws -> [CryptoPrice] {
        historicalPricesCalls.append((coinId, currency, days))
        return try historicalPricesResult.get()
    }

    func livePrice(coinId: String, currencies: [String]) async throws -> LivePrice {
        livePriceCalls.append((coinId, currencies))
        return try livePriceResult.get()
    }

    func priceDetails(coinId: String, date: Date) async throws -> PriceDetails {
        priceDetailsCalls.append((coinId, date))
        return try priceDetailsResult.get()
    }
}
