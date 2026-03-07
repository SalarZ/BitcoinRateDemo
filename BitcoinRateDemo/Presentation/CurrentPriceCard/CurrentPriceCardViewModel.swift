//
//  CurrentPriceCardViewModel.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation
import Combine

@MainActor
final class CurrentPriceCardViewModel: ObservableObject {
    @Published private(set) var state: ViewState<LivePriceViewItem> = .loading

    private let coinId = AppConstants.Coin.bitcoinId
    private let currency = AppConstants.Currency.eur

    private let getCryptoCurrentPriceUseCase: CryptoCurrentPriceUseCase

    init(getCryptoCurrentPriceUseCase: CryptoCurrentPriceUseCase) {
        self.getCryptoCurrentPriceUseCase = getCryptoCurrentPriceUseCase
    }

    func load() async {
        state = .loading
        do {
            let pricePoint = try await getCryptoCurrentPriceUseCase.execute(coinId: coinId, currency: currency)
            let livePrice = LivePriceViewItem(
                priceText: pricePoint.price.currencyFormatted(code: currency),
                lastUpdated: pricePoint.date.hourMinuteSecondFormatted)
            state = .success(livePrice)
        } catch {
            state = .failure(error.localizedDescription)
        }
    }
}
