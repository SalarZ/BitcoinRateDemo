//
//  BitcoinHistoryItemsViewModel.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation
import Combine

@MainActor
final class BitcoinHistoryItemsViewModel: ObservableObject {
    @Published private(set) var state: ViewState<[PriceRow]> = .loading

    private let priceHistoryUseCase: CryptoPriceHistoryUseCase
    private let onSelection: (PricePoint) -> Void

    init(getCryptoHistoryUseCase: CryptoPriceHistoryUseCase,
         onSelection: @escaping (PricePoint) -> Void) {
        self.priceHistoryUseCase = getCryptoHistoryUseCase
        self.onSelection = onSelection
    }

    func load() async {
        state = .loading
        do {
            let points = try await priceHistoryUseCase.execute(
                coinId: AppConstants.Coin.bitcoinId,
                currency: AppConstants.Currency.eur,
                days: AppConstants.API.priceHistoryDays)
            state = .success(points.map { makePriceRow(from: $0) })
        } catch {
            state = .failure(error.localizedDescription)
        }
    }

    private func makePriceRow(from item: PricePoint) -> PriceRow {
        PriceRow(formattedDate: item.date.yearMonthDayFormatted,
                 formattedPrice: item.price.currencyFormatted(code: AppConstants.Currency.eur),
        onSelect: { [weak self] in
            self?.onSelection(item)
        })
    }
}
