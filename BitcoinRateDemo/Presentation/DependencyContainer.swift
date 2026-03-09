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
    let appCoordinator = AppCoordinator()
    let priceHistoryUseCase: CryptoPriceHistoryUseCase
    let currentPriceUseCase: CryptoCurrentPriceUseCase
    let priceDetailsUseCase: CryptoPriceDetailsUseCase
    let livePriceDetailsUseCase: CryptoLivePriceDetailsUseCase

    private(set) lazy var cryptoHistoryItemsViewModel: CryptoHistoryItemsViewModel = {
        CryptoHistoryItemsViewModel(
            getCryptoHistoryUseCase: priceHistoryUseCase,
            onSelection: { [weak appCoordinator] in appCoordinator?.navigate(to: .priceDetails($0)) }
        )
    }()

    private(set) lazy var livePriceCardViewModel: LivePriceCardViewModel = {
        LivePriceCardViewModel(
            getCryptoCurrentPriceUseCase: currentPriceUseCase,
            onSelection: { [weak appCoordinator] in
                appCoordinator?.navigate(to: .livePriceDetails(coinId: $0)) }
        )
    }()

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
