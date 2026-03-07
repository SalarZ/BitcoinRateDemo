//
//  CryptoPriceHistoryUseCase.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation

protocol CryptoPriceHistoryUseCase {
    func execute(coinId: String, currency: String, days: Int) async throws -> [PricePoint]
}

struct DefaultCryptoPriceHistoryUseCase: CryptoPriceHistoryUseCase {
    private let repository: CryptoPriceRepository
    private let calendar = Calendar.current

    init(repository: CryptoPriceRepository) {
        self.repository = repository
    }

    func execute(coinId: String, currency: String, days: Int) async throws -> [PricePoint] {
        let history = try await repository.historicalPrices(coinId: coinId, currency: currency, days: days)

        /// Remove **today** from the list.
        return history
            .filter { !calendar.isDateInToday($0.date) }
            .reversed()
    }
}
