//
//  PriceDetailsViewModelTests.swift
//  BitcoinRateDemoTests
//
//  Created by Salar on 3/8/26.
//

import Testing
import Foundation
@testable import BitcoinRateDemo

@MainActor
struct PriceDetailsViewModelTests {
    @Test("initial state is loading")
    func initialStateIsLoading() {
        let sut = PriceDetailsViewModel(loader: { throw CryptoRepositoryError.unexpected })

        guard case .loading = sut.state else {
            Issue.record("Expected .loading initial state")
            return
        }
    }

    @Test("load() maps HistoryDetails into formatted DetailsViewItem")
    func loadMapsToViewItem() async {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let details = PriceDetails(name: "Bitcoin", eurPrice: 44_000, usdPrice: 47_000, gbpPrice: 37_000, lastUpdate: date)
        let sut = PriceDetailsViewModel(loader: { details })

        await sut.load()

        guard case .success(let item) = sut.state else {
            Issue.record("Expected .success state")
            return
        }
        #expect(!item.date.isEmpty)
        #expect(!item.eurPrice.isEmpty)
        #expect(!item.usdPrice.isEmpty)
        #expect(!item.gbpPrice.isEmpty)

        // Prices should not be dashes when values are present
        #expect(item.eurPrice != "-")
        #expect(item.usdPrice != "-")
        #expect(item.gbpPrice != "-")
    }

    @Test("load() shows dash for nil prices")
    func loadShowsDashForNilPrices() async {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let details = PriceDetails(name: "Bitcoin", eurPrice: nil, usdPrice: nil, gbpPrice: nil, lastUpdate: date)
        let sut = PriceDetailsViewModel(loader: { details })

        await sut.load()

        guard case .success(let item) = sut.state else {
            Issue.record("Expected .success state")
            return
        }
        #expect(item.eurPrice == "-")
        #expect(item.usdPrice == "-")
        #expect(item.gbpPrice == "-")
    }

    @Test("load() transitions to failure on error")
    func loadFailure() async {
        let sut = PriceDetailsViewModel(loader: { throw CryptoRepositoryError.serverError(statusCode: 500) })

        await sut.load()

        guard case .failure(let message) = sut.state else {
            Issue.record("Expected .failure state after load() with error")
            return
        }
        #expect(!message.isEmpty)
    }
}
