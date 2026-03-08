//
//  RootView.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/8/26.
//

import SwiftUI

struct RootView: View {
    @Environment(\.container) private var container
    @StateObject private var coordinator = AppCoordinator()

    var body: some View {
        NavigationView {
            Self._printChanges()
            return BitcoinHistoryView(
                bitcoinHistoryItemsViewModel: BitcoinHistoryItemsViewModel(
                    getCryptoHistoryUseCase: container.priceHistoryUseCase
                ),
                currentPriceCardViewModel: CurrentPriceCardViewModel(
                    getCryptoCurrentPriceUseCase: container.currentPriceUseCase)
            )
        }
    }
}

#Preview {
    RootView()
}
