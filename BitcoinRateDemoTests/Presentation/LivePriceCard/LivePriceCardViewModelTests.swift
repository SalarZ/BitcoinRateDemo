//
//  LivePriceCardViewModelTests.swift
//  BitcoinRateDemoTests
//
//  Created by Salar on 3/7/26.
//

import Testing
import Foundation
@testable import BitcoinRateDemo

@MainActor
struct LivePriceCardViewModelTests {

    @Test("initial state is loading")
    func initialStateIsLoading() async throws {
        let (sut, _) = makeSUT()

        #expect(sut.state == .loading)
    }

    @Test("start() calls use case once")
    func startCallsUseCaseOnce() async {
        let (sut, useCase) = makeSUT()

        sut.start()

        await Task.yield()

        #expect(useCase.executeCalls.count == 1)
        let firstCall = useCase.executeCalls.first!
        #expect(firstCall.0 == AppConstants.Coin.bitcoinId)
        #expect(firstCall.1 == AppConstants.Currency.eur)
    }

    @Test("start() ignores second call")
    func startCallsUseCaseOnceOnMultipleCalled() async {
        let (sut, useCase) = makeSUT()

        sut.start()
        sut.start()

        await Task.yield()
        await Task.yield()

        #expect(useCase.executeCalls.count == 1)
    }

    @Test("start() transitions to success with mapped PriceRows")
    func startSuccess() async {
        let anyResult = Self.makeResult()
        let (sut, _) = makeSUT(result: .success(anyResult))

        sut.start()

        await Task.yield()

        guard case .loaded(let item) = sut.state else {
            Issue.record("Expected .success state after load()")
            return
        }

        #expect(!item.id.uuidString.isEmpty)
        #expect(item.lastUpdated == anyResult.date.hourMinuteSecondFormatted)
        #expect(item.price == anyResult.price.currencyFormatted(code: AppConstants.Currency.eur))
    }

    @Test("start() transitions to failure on error")
    func startFailure() async {
        let anyError = NSError(domain: "any-error", code: 0)
        let (sut, _) = makeSUT(result: .failure(anyError))

        sut.start()

        await Task.yield()

        guard case .failure(let message) = sut.state else {
            Issue.record("Expected .failure state after load() with error")
            return
        }
        #expect(!message.isEmpty)
    }

    @Test("start() triggeres the price refresh")
    func startTriggersRefreshing() async {
        _ = Self.makeResult()
        let (sut, useCase) = makeSUT(refreshInterval: 0.1)

        sut.start()

        try? await Task.sleep(seconds: 0.15)

        #expect(useCase.executeCalls.count == 2)
    }

    @Test("manualRetry() triggers a price refresh")
    func manualRetryTriggersRefresh() async {
        _ = Self.makeResult()
        let (sut, useCase) = makeSUT()

        await sut.manualRetry()

        #expect(useCase.executeCalls.count == 1)
    }

    @Test("manualRetry() triggers a price refresh")
    func refreshSetStaleOnFailureWhenWeHaveTheLastPrice() async {
        let anyError = NSError(domain: "any-error", code: 0)
        let (sut, useCase) = makeSUT(refreshInterval: 0.1)

        sut.start()

        await Task.yield()

        useCase.result = .failure(anyError)

        await sut.manualRetry()

        guard case .stale = sut.state else {
            Issue.record("Expected .stale state")
            return
        }
    }

    @Test("onSelect triggers onSelection closure")
    func onSelectTriggersOnSelection() async {
        await confirmation { confirmation in
            let (sut, _) = makeSUT(onSelection: { coinId in
                confirmation.confirm()
            })

            sut.onSelect()
        }
    }

    // MARK: - Helpers
    private func makeSUT(result: Result<CryptoPrice, Error> = .success(Self.makeResult()),
                         refreshInterval: TimeInterval = 1,
                         onSelection: @escaping (String) -> Void = { _ in }
    ) -> (sut: LivePriceCardViewModel, useCase: MockCryptoCurrentPriceUseCase) {
        let useCase = MockCryptoCurrentPriceUseCase(result: result)
        let sut = LivePriceCardViewModel(getCryptoCurrentPriceUseCase: useCase, refreshInterval: refreshInterval, onSelection: onSelection)

        return (sut, useCase)
    }

    private static func makeResult(date: Date = .now, price: Double = 123.123, coinId: String = "btc") -> CryptoPrice {
        CryptoPrice(date: date, price: price, coinId: coinId)
    }
}

private final class MockCryptoCurrentPriceUseCase: CryptoCurrentPriceUseCase {
    enum DelayMode {
        case none
        case sleep(TimeInterval)
        case yield
    }

    private(set) var executeCalls: [(String, String)] = []
    private var delayMode: DelayMode = .none

    var result: Result<CryptoPrice, Error>

    init(result: Result<CryptoPrice, Error>) {
        self.result = result
    }

    func execute(coinId: String, currency: String) async throws -> CryptoPrice {
        executeCalls.append((coinId, currency))
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
