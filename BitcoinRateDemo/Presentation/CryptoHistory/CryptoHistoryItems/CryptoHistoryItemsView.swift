//
//  CryptoHistoryItemsView.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import SwiftUI

struct CryptoHistoryItemsView: View {
    @EnvironmentObject private var container: DependencyContainer
    @StateObject private var viewModel: CryptoHistoryItemsViewModel

    init(viewModel: CryptoHistoryItemsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Section(String(localized: "history.section.history")) {
            switch viewModel.state {
            case .loading:
                loadingView
            case .loaded(let items):
                ForEach(items) { item in
                    HStack {
                        Text(item.date)
                        Spacer()
                        Text(item.price)
                            .monospacedDigit()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        item.onSelect()
                    }
                }

            case .failure(let error):
                ErrorView(message: error) {
                    await viewModel.load()
                }
                .padding()
            }
        }
        .task {
            await viewModel.loadIfNeeded()
        }
    }

    private var loadingView: some View {
        HStack {
            Spacer()
            ProgressView()
                .id(UUID())
            Spacer()
        }
    }
}

#Preview("Success state") {
    CryptoHistoryItemsView(
        viewModel:
            CryptoHistoryItemsViewModel(
                getCryptoHistoryUseCase: PreviewMocks.getCryptoHistoryUseCase(),
                onSelection: { _ in }
            )
    )
}

#Preview("Failue state") {
    CryptoHistoryItemsView(
        viewModel:
            CryptoHistoryItemsViewModel(
                getCryptoHistoryUseCase: PreviewMocks.getCryptoHistoryUseCase(mode: .failure),
                onSelection: { _ in }
            )
    )
}
