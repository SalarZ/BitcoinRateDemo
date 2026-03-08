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
            BitcoinHistoryView(
                bitcoinHistoryItemsViewModel: BitcoinHistoryItemsViewModel(
                    getCryptoHistoryUseCase: container.priceHistoryUseCase,
                    onSelection: { coordinator.navigate(to: .priceDetails($0)) }
                ),
                currentPriceCardViewModel: CurrentPriceCardViewModel(
                    getCryptoCurrentPriceUseCase: container.currentPriceUseCase,
                    onSelection: { coordinator.navigate(to: .livePriceDetails(coinId: $0))})
            )
            .background(hiddenLink)
        }
    }

    @ViewBuilder
    private var hiddenLink: some View {
        NavigationLink(
            isActive: Binding(
                get: { coordinator.activeRoute != nil },
                set: { if !$0 { coordinator.pop() }}
            ),
            destination: {
                destinationView
            }, label: { EmptyView() })
        .hidden()
    }

    @ViewBuilder
    private var destinationView: some View {
        switch coordinator.activeRoute {
        case .priceDetails(let price):
            PriceDetailsView(viewModel: PriceDetailsViewModel(loader: {
                try await container.priceDetailsUseCase.execute(coinId: price.coinId, date: price.date)
            }))
        case .livePriceDetails(let coinId):
            PriceDetailsView(viewModel: PriceDetailsViewModel(loader: {
                try await container.livePriceDetailsUseCase.execute(coinId: coinId)
            }))
        case .none:
            EmptyView()
        }
    }
}

#Preview {
    RootView()
}
