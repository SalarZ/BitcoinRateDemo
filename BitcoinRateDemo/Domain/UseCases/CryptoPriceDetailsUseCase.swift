//
//  CryptoPriceDetailsUseCase.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/8/26.
//

import Foundation

protocol CryptoPriceDetailsUseCase {
    func execute(coinId: String, date: Date) async throws -> CryptoDetails
}

struct DefaultCryptoPriceDetailsUseCase: CryptoPriceDetailsUseCase {
    private let repository: CryptoPriceRepository

    init(repository: CryptoPriceRepository) {
        self.repository = repository
    }

    func execute(coinId: String, date: Date) async throws -> CryptoDetails {
        return try await repository.priceDetails(coinId: coinId, date: date)
    }
}
