//
//  DependencyContainer.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/8/26.
//

import Foundation
import Combine

@MainActor
final class DependencyContainer: ObservableObject {
    let priceHistoryUseCase: CryptoPriceHistoryUseCase
    let currentPriceUseCase: CryptoCurrentPriceUseCase
    let priceDetailsUseCase: CryptoPriceDetailsUseCase
    let livePriceDetailsUseCase: CryptoLivePriceDetailsUseCase

    init() {
        let networkClient = DefaultNetworkClient(
            httpClient: URLSession.shared,
            baseURL: AppConstants.API.baseURL,
            requestAuthorizer: APIKeyAuthorizer(apiKey: AppConfiguration.coinGeckoAPIKey))

        let networkRepo = NetworkCryptoPriceRepository(networkClient: networkClient)
        priceHistoryUseCase = DefaultCryptoPriceHistoryUseCase(repository: networkRepo)
        currentPriceUseCase = DefaultCryptoCurrentPriceUseCase(repository: networkRepo)
        priceDetailsUseCase = DefaultCryptoPriceDetailsUseCase(repository: networkRepo)
        livePriceDetailsUseCase = DefaultLivePriceDetailsUseCase(repository: networkRepo)
    }
}
