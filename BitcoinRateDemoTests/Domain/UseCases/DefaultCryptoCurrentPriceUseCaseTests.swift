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

    @Test("returns correct CryptoPrice for requested currency")
    func returnsCryptoPrice() async throws {
        let repo = MockCryptoPriceRepository()
        repo.livePriceResult = .success(
            LivePrice(name: "bitcoin", prices: ["eur": 45_000.0, "usd": 48_000.0], lastUpdate: fixedDate)
        )
        let sut = DefaultCryptoCurrentPriceUseCase(repository: repo)

        let crypto = try await sut.execute(coinId: "bitcoin", currency: "eur")

        #expect(repo.livePriceCalls.count == 1)

        let firstCallItem = try #require(repo.livePriceCalls.first)
        #expect(firstCallItem.coinId == "bitcoin")
        #expect(firstCallItem.currencies == ["eur"])

        #expect(crypto.price == 45_000.0)
        #expect(crypto.coinId == "bitcoin")
        #expect(crypto.date == fixedDate)
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
