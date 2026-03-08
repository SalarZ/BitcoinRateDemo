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

enum CryptoCurrentPriceError: Error, Equatable {
    case missingPrice(currency: String, availableCurrencies: [String])
}

struct DefaultCryptoCurrentPriceUseCase: CryptoCurrentPriceUseCase {
    private let repository: CryptoPriceRepository

    init(repository: CryptoPriceRepository) {
        self.repository = repository
    }

    func execute(coinId: String, currency: String) async throws -> CryptoPrice {
        let response = try await repository.livePrice(coinId: coinId, currencies: [currency])
        guard let price = response.prices[currency] else {
            throw CryptoCurrentPriceError.missingPrice(
                currency: currency,
                availableCurrencies: response.prices.keys.sorted()
            )
        }

        return CryptoPrice(date: response.lastUpdate, price: price, coinId: coinId)
    }
}
