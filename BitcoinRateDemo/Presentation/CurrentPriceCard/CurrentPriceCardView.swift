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
            }

            switch viewModel.state {
            case .loading:
                Text("price.card.loading")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .redacted(reason: .placeholder)

            case .success(let price):
                Text(String(localized: "price.card.updated \(price.lastUpdated)"))
                    .font(.footnote)
                    .foregroundStyle(.secondary)

            case .failure(let err):
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("price.card.failed")
                            .font(.footnote)
                            .fontWeight(.semibold)
                        Text(err)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        Task { await viewModel.load() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }

    private var primaryText: String {
        switch viewModel.state {
        case .loading, .failure:
            return String(localized: "price.card.placeholder")
        case .success(let price):
            return price.priceText
        }
    }
}

#Preview("Success state") {
    CurrentPriceCardView(viewModel: CurrentPriceCardViewModel(getCryptoCurrentPriceUseCase: MockGetCryptoCurrentPriceUseCase()))

}

#Preview("Failure state") {
    CurrentPriceCardView(viewModel: CurrentPriceCardViewModel(getCryptoCurrentPriceUseCase: MockGetCryptoCurrentPriceUseCase(isSuccess: false)))
}

private final class MockGetCryptoCurrentPriceUseCase: CryptoCurrentPriceUseCase {
    private let delayDuration: TimeInterval
    private let isSuccess: Bool

    init(delayDuration: TimeInterval = 1.0, isSuccess: Bool = true) {
        self.delayDuration = delayDuration
        self.isSuccess = isSuccess
    }

    func execute(coinId: String, currency: String) async throws -> PricePoint {
        try? await Task.sleep(nanoseconds: UInt64(delayDuration) * 1_000_000_000)
        guard isSuccess else { throw NSError(domain: "", code: 0, userInfo: nil)}
        return PricePoint(date: Date.now, price: 1234.1234, coinId: "bitcoin")
    }
}
