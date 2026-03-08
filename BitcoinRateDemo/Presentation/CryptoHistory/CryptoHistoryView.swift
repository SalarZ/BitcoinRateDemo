//
//  CryptoHistoryView.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import SwiftUI

struct CryptoHistoryView: View {
    @ObservedObject var cryptoHistoryItemsViewModel: CryptoHistoryItemsViewModel
    @ObservedObject var livePriceCardViewModel: LivePriceCardViewModel

    var body: some View {
        List {
            Section(String(localized: "history.section.today")) {
                LivePriceCardView(viewModel: livePriceCardViewModel)
            }

            CryptoHistoryItemsView(viewModel: cryptoHistoryItemsViewModel)
        }
        .navigationTitle(String(localized: "history.nav.title"))
    }
}

#Preview {
    CryptoHistoryView(
        cryptoHistoryItemsViewModel:
            CryptoHistoryItemsViewModel(
                getCryptoHistoryUseCase: PreviewMocks.getCryptoHistoryUseCase(),
                onSelection: { _ in }
            ),
        livePriceCardViewModel:
            LivePriceCardViewModel(
                getCryptoCurrentPriceUseCase: PreviewMocks.getCryptoCurrentPriceUseCase(),
                onSelection: { _ in })
        )
}
