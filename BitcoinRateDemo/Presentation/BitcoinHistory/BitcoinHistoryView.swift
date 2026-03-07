//
//  BitcoinHistoryView.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import SwiftUI

struct BitcoinHistoryView: View {
    @StateObject private var viewModel: BitcoinHistoryViewModel

    init(viewModel: BitcoinHistoryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List {
            switch viewModel.state {
            case .loading:
                loadingView
            case .success(let items):
                Section("History") {
                    ForEach(items) { item in
                        HStack {
                            Text(item.formattedDate)
                            Spacer()
                            Text(item.formattedPrice)
                                .monospacedDigit()
                        }
                    }
                }
            case .failure(let string):
                makeErrorView(errorMessage: string)
            }
        }
        .navigationTitle(String(localized: "History"))
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
    private func makeErrorView(errorMessage: String) -> some View {
        VStack(spacing: 12) {
            Text("failed to load")
                .font(.headline)
            Text(errorMessage)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Button("retry") {
                Task {
                    await viewModel.load()
                }
            }
        }
        .padding()
    }
}

#Preview {
    BitcoinHistoryView(viewModel: BitcoinHistoryViewModel(getCryptoHistoryUseCase: MockCryptoHistoryUseCase()))
}

#Preview {
    BitcoinHistoryView(viewModel: BitcoinHistoryViewModel(getCryptoHistoryUseCase: MockCryptoHistoryUseCase(isSuccess: false)))
}

private struct MockCryptoHistoryUseCase: CryptoPriceHistoryUseCase {
    var delayDuration: TimeInterval
    var isSuccess: Bool

    init(delayDuration: TimeInterval = 1.0, isSuccess: Bool = true) {
        self.delayDuration = delayDuration
        self.isSuccess = isSuccess
    }

    func execute(coinId: String, currency: String, days: Int) async throws -> [PricePoint] {
        try? await Task.sleep(nanoseconds: UInt64(delayDuration) * 1_000_000_000)
        guard isSuccess else { throw NSError(domain: "", code: 0, userInfo: nil)}
        return (0..<days).map { i in
            PricePoint(date: makeDate(daysAgo: i), price: Double(i), coinId: "bitcoin")
        }
    }

    private func makeDate(daysAgo: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -daysAgo, to: .now)!
    }

}
