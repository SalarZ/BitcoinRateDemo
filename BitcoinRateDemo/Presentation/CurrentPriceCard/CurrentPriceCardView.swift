//
//  CurrentPriceCardView.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import SwiftUI

struct CurrentPriceCardView: View {
    @ObservedObject var viewModel: CurrentPriceCardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("price.card.label")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(primaryText)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                        .redacted(reason: viewModel.state == .loading ? .placeholder : [])
                }

                Spacer()

                HStack(spacing: 8) {
                    if let badge = badgeText {
                        BadgeView(text: badge)
                    }
                }
            }

            switch viewModel.state {
            case .loading:
                Text("price.card.loading")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .redacted(reason: .placeholder)

            case .loaded(let price):
                Text(String(localized: "price.card.updated \(price.lastUpdated)"))
                    .font(.footnote)
                    .foregroundStyle(.secondary)

            case .stale:
                HStack {
                    Text("price.card.stale")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Spacer()
                    retryButton
                }

            case .failure(let err):
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("price.card.failed")
                            .font(.footnote)
                            .fontWeight(.semibold)
                        Text(err)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()

                    retryButton
                }
            }
        }
        .task {
            viewModel.start()
        }
    }

    private var primaryText: String {
        switch viewModel.state {
        case .loading, .failure:
            return String(localized: "price.card.placeholder")
        case .loaded(let price), .stale(let price):
            return price.priceText
        }
    }

    private var badgeText: String? {
        switch viewModel.state {
        case .loaded:  return String(localized: "price.card.badge.live")
        case .stale:   return String(localized: "price.card.badge.stale")
        default:       return nil
        }
    }

    @ViewBuilder
    private var retryButton: some View {
        if viewModel.isRefreshing {
            ProgressView()
        } else {
            Button {
                Task { await viewModel.manualRetry() }
            } label: {
                Image(systemName: "arrow.clockwise")
            }
        }
    }
}

#Preview("Success state") {
    CurrentPriceCardView(viewModel: CurrentPriceCardViewModel(getCryptoCurrentPriceUseCase: MockGetCryptoCurrentPriceUseCase()))

}

#Preview("Stale state") {
    CurrentPriceCardView(viewModel: CurrentPriceCardViewModel(getCryptoCurrentPriceUseCase: MockGetCryptoCurrentPriceUseCaseStaleState(), refreshInterval: 1))

}

#Preview("Failure state") {
    CurrentPriceCardView(viewModel: CurrentPriceCardViewModel(getCryptoCurrentPriceUseCase: MockGetCryptoCurrentPriceUseCase(isSuccess: false)))
}

#Preview("Refresh") {
    CurrentPriceCardView(viewModel: CurrentPriceCardViewModel(getCryptoCurrentPriceUseCase: MockGetCryptoCurrentPriceUseCase(isSuccess: true), refreshInterval: 5))
}

final class MockGetCryptoCurrentPriceUseCase: CryptoCurrentPriceUseCase {
    private let delayDuration: TimeInterval
    private let isSuccess: Bool

    init(delayDuration: TimeInterval = 1.0, isSuccess: Bool = true) {
        self.delayDuration = delayDuration
        self.isSuccess = isSuccess
    }

    func execute(coinId: String, currency: String) async throws -> PricePoint {
        try? await Task.sleep(seconds: delayDuration)
        guard isSuccess else { throw NSError(domain: "", code: 0, userInfo: nil)}
        return PricePoint(date: Date.now, price: 1234.1234, coinId: "bitcoin")
    }
}

final class MockGetCryptoCurrentPriceUseCaseStaleState: CryptoCurrentPriceUseCase {
    private let delayDuration: TimeInterval
    private var executeCalled = false

    init(delayDuration: TimeInterval = 1) {
        self.delayDuration = delayDuration
    }

    func execute(coinId: String, currency: String) async throws -> PricePoint {
        try? await Task.sleep(seconds: delayDuration)
        guard !executeCalled else {
            executeCalled.toggle()
            throw NSError(domain: "", code: 0, userInfo: nil)
        }

        executeCalled.toggle()
        return PricePoint(date: Date.now, price: 1234.1234, coinId: "bitcoin")
    }
}
