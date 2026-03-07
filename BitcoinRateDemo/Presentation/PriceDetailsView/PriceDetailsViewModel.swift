//
//  PriceDetailsViewModel.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation
import OSLog
import Combine

@MainActor
final class PriceDetailsViewModel: ObservableObject {
    @Published private(set) var state: ViewState<PriceDetailsItem> = .loading

    private static let logger = Logger(subsystem: AppConstants.Logging.subsystem,
                                       category: "DetailsViewModel")

    private let loader: () async throws -> PriceDetails

    init(loader: @escaping () async throws -> PriceDetails) {
        self.loader = loader
    }

    func load() async {
        state = .loading
        do {
            state = .success(detailsViewItem(from: try await loader()))
        } catch {
            Self.logger.error("Failed to load price details: \(error.localizedDescription, privacy: .public)")
            state = .failure(error.localizedDescription)
        }
    }

    private func detailsViewItem(from details: PriceDetails) -> PriceDetailsItem {
        PriceDetailsItem(
            date: details.lastUpdate.yearMonthDayFormatted,
            eurPrice: details.eurPrice?.currencyFormatted(code: AppConstants.Currency.eur) ?? "-",
            usdPrice: details.usdPrice?.currencyFormatted(code: AppConstants.Currency.usd) ?? "-",
            gbpPrice: details.gbpPrice?.currencyFormatted(code: AppConstants.Currency.gbp) ?? "-")
    }
}
