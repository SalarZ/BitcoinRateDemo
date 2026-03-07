//
//  BitcoinRateDemoApp.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import SwiftUI

@main
struct BitcoinRateDemoApp: App {
    private let getCryptoHistoryUseCase: CryptoPriceHistoryUseCase
    private let getCryptoCurrentPriceUseCase: CryptoCurrentPriceUseCase

    init() {
        let networkClient = DefaultNetworkClient(
            httpClient: URLSession.shared,
            baseURL: AppConstants.API.baseURL,
            requestAuthorizer: APIKeyAuthorizer(apiKey: AppConfiguration.coinGeckoAPIKey))

        let repository = NetworkCryptoPriceRepository(networkClient: networkClient)
        self.getCryptoHistoryUseCase = DefaultCryptoPriceHistoryUseCase(repository: repository)
        self.getCryptoCurrentPriceUseCase = DefaultCryptoCurrentPriceUseCase(repository: repository)
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                BitcoinHistoryView(
                    bitcoinHistoryItemsViewModel: BitcoinHistoryItemsViewModel(getCryptoHistoryUseCase: getCryptoHistoryUseCase),
                    currentPriceCardViewModel: CurrentPriceCardViewModel(getCryptoCurrentPriceUseCase: getCryptoCurrentPriceUseCase))
            }
        }
    }
}
