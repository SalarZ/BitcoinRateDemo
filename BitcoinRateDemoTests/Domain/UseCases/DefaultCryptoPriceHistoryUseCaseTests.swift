//
//  DefaultCryptoPriceHistoryUseCaseTests.swift
//  BitcoinRateDemoTests
//
//  Created by Salar on 3/7/26.
//

import Testing
import Foundation
@testable import BitcoinRateDemo

struct DefaultCryptoPriceHistoryUseCaseTests {

    @Test("strips today and reverses order")
    func stripsAndReverses() async throws {
        let days = 14
        let cryptoPrices: [CryptoPrice] = (0..<days).map { i in
            CryptoPrice(date: makeDate(daysAgo: i), price: Double(i), coinId: "bitcoin")
        }
        let repo = MockCryptoPriceRepository()
        repo.historicalPricesResult = .success(cryptoPrices)
        let sut = DefaultCryptoPriceHistoryUseCase(repository: repo)

        let result = try await sut.execute(coinId: "bitcoin", currency: "eur", days: days)

        #expect(repo.historicalPricesCalls.count == 1)

        let firstCallItem = try #require(repo.historicalPricesCalls.first)
        #expect(firstCallItem.coinId == "bitcoin")
        #expect(firstCallItem.currency == "eur")
        #expect(firstCallItem.days == days)

        #expect(result.count == days - 1)
        #expect(result.first?.price == 13.0)
        #expect(result.last?.price == 1.0)
    }

    @Test("returns empty array when repository returns empty")
    func emptyRepository() async throws {
        let repo = MockCryptoPriceRepository()
        repo.historicalPricesResult = .success([])
        let sut = DefaultCryptoPriceHistoryUseCase(repository: repo)

        let result = try await sut.execute(coinId: "bitcoin", currency: "eur", days: 14)

        #expect(result.isEmpty)
    }

    @Test("propagates repository errors")
    func propagatesError() async throws {
        let repo = MockCryptoPriceRepository()
        repo.historicalPricesResult = .failure(CryptoRepositoryError.noConnection)
        let sut = DefaultCryptoPriceHistoryUseCase(repository: repo)

        await #expect(throws: CryptoRepositoryError.noConnection) {
            try await sut.execute(coinId: "bitcoin", currency: "eur", days: 14)
        }
    }

    // MARK: - Helpers
    private func makeDate(daysAgo: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -daysAgo, to: .now)!
    }
}
