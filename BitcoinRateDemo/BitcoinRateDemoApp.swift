//
//  BitcoinRateDemoApp.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import SwiftUI

@main
struct BitcoinRateDemoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                BitcoinHistoryView(
                    bitcoinHistoryItemsViewModel: BitcoinHistoryItemsViewModel(getCryptoHistoryUseCase: MockCryptoHistoryUseCase()),
                    currentPriceCardViewModel: CurrentPriceCardViewModel(getCryptoCurrentPriceUseCase: MockGetCryptoCurrentPriceUseCase(), refreshInterval: 5))
            }
        }
    }
}
