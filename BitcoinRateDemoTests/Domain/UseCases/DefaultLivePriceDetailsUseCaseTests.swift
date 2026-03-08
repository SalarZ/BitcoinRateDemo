//
//  DefaultLivePriceDetailsUseCaseTests.swift
//  BitcoinRateDemoTests
//
//  Created by Salar on 3/8/26.
//

import Testing
import Foundation
@testable import BitcoinRateDemo

struct DefaultLivePriceDetailsUseCaseTests {

    private let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)

    @Test("maps EUR, USD and GBP prices into HistoryDetails")
    func mapsAllPrices() async throws {
        let repo = MockCryptoPriceRepository()
        repo.livePriceResult = .success(
            LivePrice(name: "bitcoin",
                      prices: ["eur": 44_000, "usd": 47_000, "gbp": 37_000],
                      lastUpdate: fixedDate)
        )
        let sut = DefaultLivePriceDetailsUseCase(repository: repo)

        let result = try await sut.execute(coinId: "bitcoin")

        #expect(result.eurPrice == 44_000)
        #expect(result.usdPrice == 47_000)
        #expect(result.gbpPrice == 37_000)
        #expect(result.lastUpdate == fixedDate)
    }

    @Test("sets missing currencies to nil")
    func setsMissingCurrenciesToNil() async throws {
        let repo = MockCryptoPriceRepository()
        repo.livePriceResult = .success(
            LivePrice(name: "bitcoin", prices: ["eur": 44_000], lastUpdate: fixedDate)
        )
        let sut = DefaultLivePriceDetailsUseCase(repository: repo)

        let result = try await sut.execute(coinId: "bitcoin")

        #expect(result.eurPrice == 44_000)
        #expect(result.usdPrice == nil)
        #expect(result.gbpPrice == nil)
    }

    @Test("propagates repository errors")
    func propagatesError() async throws {
        let repo = MockCryptoPriceRepository()
        repo.livePriceResult = .failure(CryptoRepositoryError.noConnection)
        let sut = DefaultLivePriceDetailsUseCase(repository: repo)

        await #expect(throws: CryptoRepositoryError.noConnection) {
            try await sut.execute(coinId: "bitcoin")
        }
    }

}
