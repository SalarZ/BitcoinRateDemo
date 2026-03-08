//
//  CryptoHistoryView.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import SwiftUI

struct CryptoHistoryView: View {
    @StateObject var cryptoHistoryItemsViewModel: CryptoHistoryItemsViewModel
    @StateObject var livePriceCardViewModel: LivePriceCardViewModel

    init(cryptoHistoryItemsViewModel: CryptoHistoryItemsViewModel,
         livePriceCardViewModel: LivePriceCardViewModel) {
        _cryptoHistoryItemsViewModel = StateObject(wrappedValue: cryptoHistoryItemsViewModel)
        _livePriceCardViewModel = StateObject(wrappedValue: livePriceCardViewModel)
    }

    var body: some View {
        List {
            Section(String(localized: "history.section.today")) {
                LivePriceCardView(viewModel: livePriceCardViewModel)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        livePriceCardViewModel.onSelect()
                    }
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
