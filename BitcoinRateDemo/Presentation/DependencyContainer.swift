//
//  DependencyContainer.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/8/26.
//

import Foundation
import SwiftUI

struct DependencyContainer {

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

// MARK: - Environment

private struct DependencyContainerKey: @MainActor EnvironmentKey {
    @MainActor static let defaultValue = DependencyContainer()
}

extension EnvironmentValues {
    @MainActor var container: DependencyContainer {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}
