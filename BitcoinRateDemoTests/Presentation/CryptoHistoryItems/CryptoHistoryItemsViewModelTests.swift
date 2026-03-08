//
//  CryptoHistoryItemsViewModelTests.swift
//  BitcoinRateDemoTests
//
//  Created by Salar on 3/7/26.
//

import Foundation
import Testing
@testable import BitcoinRateDemo

@MainActor
struct CryptoHistoryItemsViewModelTests {

    @Test("initial state is loading")
    func initialStateIsLoading() {
        let (sut, _) = makeSUT()

        guard case .loading = sut.state else {
            Issue.record("Expected .loading initial state")
            return
        }
    }

    @Test("load() calls use case once")
    func loadCallsUseCaseOnce() async {
        let (sut, useCase) = makeSUT()

        await sut.load()

        #expect(useCase.executeCalls.count == 1)
        let firstCall = useCase.executeCalls.first!
        #expect(firstCall.0 == AppConstants.Coin.bitcoinId)
        #expect(firstCall.1 == AppConstants.Currency.eur)
        #expect(firstCall.2 == AppConstants.API.priceHistoryDays)
    }

    @Test("load() transitions to success with mapped PriceRows")
    func loadSuccess() async {
        let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
        let cryptoPrices = [
            CryptoPrice(date: fixedDate, price: 40_000, coinId: "bitcoin"),
            CryptoPrice(date: fixedDate.addingTimeInterval(86400), price: 41_000, coinId: "bitcoin")
        ]
        let (sut, _) = makeSUT(result: .success(cryptoPrices))

        await sut.load()

        guard case .success(let rows) = sut.state else {
            Issue.record("Expected .success state after load()")
            return
        }
        #expect(rows.count == 2)
        #expect(!rows[0].id.uuidString.isEmpty)
        #expect(rows[0].formattedDate == cryptoPrices[0].date.yearMonthDayFormatted)
        #expect(rows[0].formattedPrice == cryptoPrices[0].price.currencyFormatted(code: AppConstants.Currency.eur))
    }

    @Test("load() transitions to failure on error")
    func loadFailure() async {
        let anyError = NSError(domain: "any-error", code: 0)
        let (sut, _) = makeSUT(result: .failure(anyError))

        await sut.load()

        guard case .failure(let message) = sut.state else {
            Issue.record("Expected .failure state after load() with error")
            return
        }
        #expect(!message.isEmpty)
    }

    @Test("load() sets state to loading before fetching")
    func loadSetsLoadingFirst() async {
        let anyError = NSError(domain: "any-error", code: 0)
        let (sut, useCase) = makeSUT(result: .failure(anyError))

        await sut.load()

        #expect(sut.state != .loading)

        useCase.result = .success([])
        useCase.setDelayMode(.yield)

        let loadTask = Task {
            await sut.load()
        }

        await Task.yield()

        #expect(sut.state == .loading)
        await loadTask.value
        #expect(sut.state == .success([]))
    }

    @Test("itemSelect triggers onSelection closure")
    func itemSelectTriggersOnSelection() async {
        let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
        let cryptoPrices = [
            CryptoPrice(date: fixedDate, price: 40_000, coinId: "bitcoin"),
            CryptoPrice(date: fixedDate.addingTimeInterval(86400), price: 41_000, coinId: "bitcoin")
        ]
        await confirmation { confirmation in
            let (sut, _) = makeSUT(result: .success(cryptoPrices)) { item in
                #expect(item == cryptoPrices.last)
                confirmation.confirm()
            }

            await sut.load()

            guard case .success(let items) = sut.state else {
                Issue.record("Expected .success state after load()")
                return
            }

            items.last?.onSelect()
        }
    }

    // MARK: - Helpers
    private func makeSUT(result: Result<[CryptoPrice], Error> = .success([]),
                         onSelection: @escaping (CryptoPrice) -> Void = { _ in }
    ) -> (sut: CryptoHistoryItemsViewModel, useCase: MockCryptoPriceHistoryUseCase) {
        let useCase = MockCryptoPriceHistoryUseCase(result: result)
        let sut = CryptoHistoryItemsViewModel(getCryptoHistoryUseCase: useCase, onSelection: onSelection)

        return (sut, useCase)
    }
}

final class MockCryptoPriceHistoryUseCase: CryptoPriceHistoryUseCase {
    enum DelayMode {
        case none
        case sleep(TimeInterval)
        case yield
    }

    private(set) var executeCalls: [(String, String, Int)] = []
    private var delayMode: DelayMode = .none

    var result: Result<[CryptoPrice], Error>

    init(result: Result<[CryptoPrice], Error> = .success([])) {
        self.result = result
    }

    func execute(coinId: String, currency: String, days: Int) async throws -> [CryptoPrice] {
        executeCalls.append((coinId, currency, days))
        try await applyDelay()
        return try result.get()
    }

    func setDelayMode(_ mode: DelayMode) {
        delayMode = mode
    }

    private func applyDelay() async throws {
        switch delayMode {
        case .none:
            break
        case .sleep(let duration):
            try await Task.sleep(seconds: duration)
        case .yield:
            await Task.yield()
        }
    }
}
