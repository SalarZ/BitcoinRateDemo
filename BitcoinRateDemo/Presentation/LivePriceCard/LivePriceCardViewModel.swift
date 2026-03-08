//
//  LivePriceCardViewModel.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation
import Combine

@MainActor
final class LivePriceCardViewModel: ObservableObject {

    enum State: Equatable {
        case loading
        case loaded(LivePriceViewItem)
        case stale(LivePriceViewItem)
        case failure(String)
    }

    private enum Trigger: String { case initial, timer, manual }

    @Published private(set) var state: State = .loading
    @Published private(set) var isRefreshing: Bool = false

    private let refreshInterval: TimeInterval
    private let coinId = AppConstants.Coin.bitcoinId
    private let currency = AppConstants.Currency.eur

    private var refreshTask: Task<Void, Never>?
    private var lastUpdatedPrice: LivePriceViewItem?

    private let onSelection: (String) -> Void
    private let getCryptoCurrentPriceUseCase: CryptoCurrentPriceUseCase

    init(getCryptoCurrentPriceUseCase: CryptoCurrentPriceUseCase,
         refreshInterval: TimeInterval = 60,
         onSelection: @escaping (String) -> Void) {
        self.getCryptoCurrentPriceUseCase = getCryptoCurrentPriceUseCase
        self.refreshInterval = refreshInterval
        self.onSelection = onSelection
    }

    func start() {
        guard refreshTask == nil else { return }
        refreshTask = Task {
            await refresh(trigger: .initial)
            while !Task.isCancelled {
                try? await Task.sleep(seconds: refreshInterval)
                await refresh(trigger: .timer)
            }
        }
    }

    func manualRetry() async {
        await refresh(trigger: .manual)
    }

    func onSelect() {
        onSelection(coinId)
    }

    private func refresh(trigger: Trigger) async {
        if trigger != .timer { isRefreshing = true }
        defer { isRefreshing = false }

        do {
            let price = try await getCryptoCurrentPriceUseCase.execute(coinId: coinId, currency: currency)
            let livePrice = LivePriceViewItem(
                priceText: price.price.currencyFormatted(code: currency),
                lastUpdated: price.date.hourMinuteSecondFormatted)
            lastUpdatedPrice = livePrice
            state = .loaded(livePrice)
        } catch {
            if let lastUpdatedPrice {
                state = .stale(lastUpdatedPrice)
            } else {
                state = .failure(error.localizedDescription)
            }
        }
    }
}
