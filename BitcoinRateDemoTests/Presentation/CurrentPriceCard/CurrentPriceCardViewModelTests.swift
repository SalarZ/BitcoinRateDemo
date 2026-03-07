//
//  CurrentPriceCardViewModelTests.swift
//  BitcoinRateDemoTests
//
//  Created by Salar on 3/7/26.
//

import Testing
import Foundation
@testable import BitcoinRateDemo

@MainActor
struct CurrentPriceCardViewModelTests {

    @Test("initial state is loading")
    func initialStateIsLoading() async throws {
        let anyResult = makeResult()
        let mockUseCase = MockCryptoCurrentPriceUseCase(result: .success(anyResult))
        let sut = CurrentPriceCardViewModel(getCryptoCurrentPriceUseCase: mockUseCase)

        #expect(sut.state == .loading)
    }

    @Test("start() calls use case once")
    func startCallsUseCaseOnce() async {
        let anyResult = makeResult()
        let mockUseCase = MockCryptoCurrentPriceUseCase(result: .success(anyResult))
        let sut = CurrentPriceCardViewModel(getCryptoCurrentPriceUseCase: mockUseCase)

        sut.start()

        await Task.yield()

        #expect(mockUseCase.executeCalls.count == 1)
        let firstCall = mockUseCase.executeCalls.first!
        #expect(firstCall.0 == AppConstants.Coin.bitcoinId)
        #expect(firstCall.1 == AppConstants.Currency.eur)
    }

    @Test("start() ignores second call")
    func startCallsUseCaseOnceOnMultipleCalled() async {
        let anyResult = makeResult()
        let mockUseCase = MockCryptoCurrentPriceUseCase(result: .success(anyResult))
        let sut = CurrentPriceCardViewModel(getCryptoCurrentPriceUseCase: mockUseCase)

        sut.start()
        sut.start()

        await Task.yield()
        await Task.yield()

        #expect(mockUseCase.executeCalls.count == 1)
    }

    @Test("start() transitions to success with mapped PriceRows")
    func startSuccess() async {
        let anyResult = makeResult()
        let mockUseCase = MockCryptoCurrentPriceUseCase(result: .success(anyResult))
        let sut = CurrentPriceCardViewModel(getCryptoCurrentPriceUseCase: mockUseCase)

        sut.start()

        await Task.yield()

        guard case .loaded(let item) = sut.state else {
            Issue.record("Expected .success state after load()")
            return
        }

        #expect(!item.id.uuidString.isEmpty)
        #expect(item.lastUpdated == anyResult.date.hourMinuteSecondFormatted)
        #expect(item.priceText == anyResult.price.currencyFormatted(code: AppConstants.Currency.eur))
    }

    @Test("start() transitions to failure on error")
    func startFailure() async {
        let anyError = NSError(domain: "any-error", code: 0)
        let mockUseCase = MockCryptoCurrentPriceUseCase(result: .failure(anyError))
        let sut = CurrentPriceCardViewModel(getCryptoCurrentPriceUseCase: mockUseCase)

        sut.start()

        await Task.yield()

        guard case .failure(let message) = sut.state else {
            Issue.record("Expected .failure state after load() with error")
            return
        }
        #expect(!message.isEmpty)
    }

    @Test("start() transitions to failure on error")
    func startTriggersRefreshing() async {
        let anyResult = makeResult()
        let mockUseCase = MockCryptoCurrentPriceUseCase(result: .success(anyResult))
        let sut = CurrentPriceCardViewModel(getCryptoCurrentPriceUseCase: mockUseCase, refreshInterval: 0.1)

        sut.start()

        try? await Task.sleep(seconds: 0.18)

        #expect(mockUseCase.executeCalls.count == 2)
    }

    @Test("manualRetry() triggers a price refresh")
    func manualRetryTriggersRefresh() async {
        let anyResult = makeResult()
        let mockUseCase = MockCryptoCurrentPriceUseCase(result: .success(anyResult))
        let sut = CurrentPriceCardViewModel(getCryptoCurrentPriceUseCase: mockUseCase, refreshInterval: 0.1)

        await sut.manualRetry()

        #expect(mockUseCase.executeCalls.count == 1)
    }

    @Test("manualRetry() triggers a price refresh")
    func refreshSetStaleOnFailureWhenWeHaveTheLastPrice() async {
        let anyResult = makeResult()
        let anyError = NSError(domain: "any-error", code: 0)
        let mockUseCase = MockCryptoCurrentPriceUseCase(result: .success(anyResult))
        let sut = CurrentPriceCardViewModel(getCryptoCurrentPriceUseCase: mockUseCase, refreshInterval: 0.1)

        sut.start()

        await Task.yield()

        mockUseCase.result = .failure(anyError)

        await sut.manualRetry()

        guard case .stale(let price) = sut.state else {
            Issue.record("Expected .stale state")
            return
        }
    }

    // MARK: - Helpers
    private func makeResult(date: Date = .now, price: Double = 123.123, coinId: String = "btc") -> PricePoint {
        PricePoint(date: date, price: price, coinId: coinId)
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

    var result: Result<PricePoint, Error>

    init(result: Result<PricePoint, Error>) {
        self.result = result
    }

    func execute(coinId: String, currency: String) async throws -> PricePoint {
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
