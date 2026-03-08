//
//  CryptoHistoryItemsViewModel.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation
import Combine

@MainActor
final class CryptoHistoryItemsViewModel: ObservableObject {
    @Published private(set) var state: ViewState<[PriceRow]> = .loading

    private let priceHistoryUseCase: CryptoPriceHistoryUseCase
    private let onSelection: (CryptoPrice) -> Void

    init(getCryptoHistoryUseCase: CryptoPriceHistoryUseCase,
         onSelection: @escaping (CryptoPrice) -> Void) {
        self.priceHistoryUseCase = getCryptoHistoryUseCase
        self.onSelection = onSelection
    }

    func loadIfNeeded() async {
        if case .loaded = state { return }
        await load()
    }

    func load() async {
        state = .loading
        do {
            let prices = try await priceHistoryUseCase.execute(
                coinId: AppConstants.Coin.bitcoinId,
                currency: AppConstants.Currency.eur,
                days: AppConstants.API.priceHistoryDays)
            state = .loaded(prices.map { makePriceRow(from: $0) })
        } catch {
            state = .failure(error.localizedDescription)
        }
    }

    private func makePriceRow(from item: CryptoPrice) -> PriceRow {
        PriceRow(date: item.date.yearMonthDayFormatted,
                 price: item.price.currencyFormatted(code: AppConstants.Currency.eur),
        onSelect: { [weak self] in
            self?.onSelection(item)
        })
    }
}
