//
//  BitcoinHistoryViewModel.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation
import Combine

enum ViewState<T: Equatable>: Equatable {
    case loading
    case success(T)
    case failure(String)
}

@MainActor
final class BitcoinHistoryViewModel: ObservableObject {
    @Published private(set) var state: ViewState<[PriceRow]> = .loading

    private let priceHistoryUseCase: CryptoPriceHistoryUseCase

    init(getCryptoHistoryUseCase: CryptoPriceHistoryUseCase) {
        self.priceHistoryUseCase = getCryptoHistoryUseCase
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
        PriceRow(formattedDate: item.date.formatted(.dateTime.year().month().day()),
                 formattedPrice: item.price.formatted(.currency(code: AppConstants.Currency.eur.uppercased())))
    }
}
