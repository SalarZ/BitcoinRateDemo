//
//  CryptoLivePriceDetailsUseCase.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/8/26.
//

protocol CryptoLivePriceDetailsUseCase {
    func execute(coinId: String) async throws -> CryptoDetails
}

struct DefaultLivePriceDetailsUseCase: CryptoLivePriceDetailsUseCase {
    private let repository: CryptoPriceRepository

    init(repository: CryptoPriceRepository) {
        self.repository = repository
    }

    func execute(coinId: String) async throws -> CryptoDetails {
        let response = try await repository.livePrice(coinId: coinId, currencies: AppConstants.Currency.detailCurrencies)
        return CryptoDetails(name: coinId,
                            eurPrice: response.prices[AppConstants.Currency.eur],
                            usdPrice: response.prices[AppConstants.Currency.usd],
                            gbpPrice: response.prices[AppConstants.Currency.gbp],
                            lastUpdate: response.lastUpdate)
    }
}
