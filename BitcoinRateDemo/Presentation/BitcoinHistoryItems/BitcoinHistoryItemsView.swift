//
//  BitcoinHistoryItemsView.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import SwiftUI

struct BitcoinHistoryItemsView: View {
    @StateObject private var viewModel: BitcoinHistoryItemsViewModel

    init(viewModel: BitcoinHistoryItemsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Section(String(localized: "history.section.history")) {
            switch viewModel.state {
            case .loading:
                loadingView
            case .success(let items):

                    ForEach(items) { item in
                        HStack {
                            Text(item.formattedDate)
                            Spacer()
                            Text(item.formattedPrice)
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
            await viewModel.load()
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
    BitcoinHistoryItemsView(viewModel: BitcoinHistoryItemsViewModel(getCryptoHistoryUseCase: MockCryptoHistoryUseCase(), onSelection: { _ in }))
}

#Preview("Failue state") {
    BitcoinHistoryItemsView(viewModel: BitcoinHistoryItemsViewModel(getCryptoHistoryUseCase: MockCryptoHistoryUseCase(isSuccess: false), onSelection: { _ in }))
}

struct MockCryptoHistoryUseCase: CryptoPriceHistoryUseCase {
    var delayDuration: TimeInterval
    var isSuccess: Bool

    init(delayDuration: TimeInterval = 1.0, isSuccess: Bool = true) {
        self.delayDuration = delayDuration
        self.isSuccess = isSuccess
    }

    func execute(coinId: String, currency: String, days: Int) async throws -> [CryptoPrice] {
        try? await Task.sleep(seconds: delayDuration)
        guard isSuccess else { throw NSError(domain: "", code: 0, userInfo: nil)}
        return (0..<days).map { i in
            CryptoPrice(date: makeDate(daysAgo: i), price: Double(i), coinId: "bitcoin")
        }
    }

    private func makeDate(daysAgo: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -daysAgo, to: .now)!
    }

}
