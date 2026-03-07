//
//  DefaultCryptoCurrentPriceUseCaseTests.swift
//  BitcoinRateDemoTests
//
//  Created by Salar on 3/7/26.
//

import Testing
import Foundation
@testable import BitcoinRateDemo

struct DefaultCryptoCurrentPriceUseCaseTests {

    private let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)

    @Test("returns correct PricePoint for requested currency")
    func returnsPricePoint() async throws {
        let repo = MockCryptoPriceRepository()
        repo.livePriceResult = .success(
            LivePrice(name: "bitcoin", prices: ["eur": 45_000.0, "usd": 48_000.0], lastUpdate: fixedDate)
        )
        let sut = DefaultCryptoCurrentPriceUseCase(repository: repo)

        let point = try await sut.execute(coinId: "bitcoin", currency: "eur")

        #expect(point.price == 45_000.0)
        #expect(point.coinId == "bitcoin")
        #expect(point.date == fixedDate)
    }

    @Test("throws when requested currency is missing from response")
    func throwsOnMissingCurrency() async throws {
        let repo = MockCryptoPriceRepository()
        repo.livePriceResult = .success(
            LivePrice(name: "bitcoin", prices: ["usd": 48_000.0], lastUpdate: fixedDate)
        )
        let sut = DefaultCryptoCurrentPriceUseCase(repository: repo)

        await #expect(throws: (any Error).self) {
            try await sut.execute(coinId: "bitcoin", currency: "eur")
        }
    }

    @Test("propagates repository errors")
    func propagatesError() async throws {
        let repo = MockCryptoPriceRepository()
        repo.livePriceResult = .failure(CryptoRepositoryError.serverError(statusCode: 503))
        let sut = DefaultCryptoCurrentPriceUseCase(repository: repo)

        await #expect(throws: (any Error).self) {
            try await sut.execute(coinId: "bitcoin", currency: "eur")
        }
    }
}
