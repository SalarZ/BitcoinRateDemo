//
//  BitcoinHistoryView.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import SwiftUI

struct BitcoinHistoryView: View {
    @StateObject var bitcoinHistoryItemsViewModel: BitcoinHistoryItemsViewModel
    @StateObject var currentPriceCardViewModel: CurrentPriceCardViewModel

    init(bitcoinHistoryItemsViewModel: BitcoinHistoryItemsViewModel, currentPriceCardViewModel: CurrentPriceCardViewModel) {
        _bitcoinHistoryItemsViewModel = StateObject(wrappedValue: bitcoinHistoryItemsViewModel)
        _currentPriceCardViewModel = StateObject(wrappedValue: currentPriceCardViewModel)
    }

    var body: some View {
        List {
            Section(String(localized: "history.section.today")) {
                CurrentPriceCardView(viewModel: currentPriceCardViewModel)
            }

            BitcoinHistoryItemsView(viewModel: bitcoinHistoryItemsViewModel)
        }
        .navigationTitle(String(localized: "history.nav.title"))
    }
}

#Preview {
    BitcoinHistoryView(
        bitcoinHistoryItemsViewModel: BitcoinHistoryItemsViewModel(getCryptoHistoryUseCase: MockCryptoHistoryUseCase()),
        currentPriceCardViewModel: CurrentPriceCardViewModel(getCryptoCurrentPriceUseCase: MockGetCryptoCurrentPriceUseCase()))
}
