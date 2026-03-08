//
//  Untitled.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation

protocol CryptoCurrentPriceUseCase {
    func execute(coinId: String, currency: String) async throws -> CryptoPrice
}

struct DefaultCryptoCurrentPriceUseCase: CryptoCurrentPriceUseCase {
    private let repository: CryptoPriceRepository

    init(repository: CryptoPriceRepository) {
        self.repository = repository
    }

    func execute(coinId: String, currency: String) async throws -> CryptoPrice {
        let response = try await repository.livePrice(coinId: coinId, currencies: [currency])
        guard let price = response.prices[currency] else {
            // TODO: Move it to an enum
            throw NSError(domain: "invalid", code: 0)
        }

        return CryptoPrice(date: response.lastUpdate, price: price, coinId: coinId)
    }
}
