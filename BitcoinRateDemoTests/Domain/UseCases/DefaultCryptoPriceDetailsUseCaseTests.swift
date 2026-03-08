//
//  DefaultCryptoPriceDetailsUseCaseTests.swift
//  BitcoinRateDemoTests
//
//  Created by Salar on 3/8/26.
//

import Testing
import Foundation
@testable import BitcoinRateDemo

struct DefaultCryptoPriceDetailsUseCaseTests {

    @Test("passes through HistoryDetails from repository unchanged")
    func passesThroughHistoryDetails() async throws {
        let expectedDate = Date(timeIntervalSince1970: 1_700_000_000)
        let expected = PriceDetails(name: "bitcoin", eurPrice: 44_000, usdPrice: 47_000, gbpPrice: 38_000, lastUpdate: expectedDate)
        let repo = MockCryptoPriceRepository()
        repo.priceDetailsResult = .success(expected)
        let sut = DefaultCryptoPriceDetailsUseCase(repository: repo)

        let result = try await sut.execute(coinId: "bitcoin", date: expectedDate)

        #expect(result.name == expected.name)
        #expect(result.eurPrice == expected.eurPrice)
        #expect(result.usdPrice == expected.usdPrice)
        #expect(result.gbpPrice == expected.gbpPrice)
        #expect(result.lastUpdate == expected.lastUpdate)
    }

    @Test("propagates repository errors")
    func propagatesError() async throws {
        let repo = MockCryptoPriceRepository()
        repo.priceDetailsResult = .failure(CryptoRepositoryError.unexpected)
        let sut = DefaultCryptoPriceDetailsUseCase(repository: repo)

        await #expect(throws: CryptoRepositoryError.unexpected) {
            try await sut.execute(coinId: "bitcoin", date: .now)
        }
    }
}
