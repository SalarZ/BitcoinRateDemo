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

    @Test
    func initialStateIsLoading() async throws {
        let anyResult = makeResult()
        let mockUseCase = MockCryptoCurrentPriceUseCase(result: .success(anyResult))
        let sut = CurrentPriceCardViewModel(getCryptoCurrentPriceUseCase: mockUseCase)

        #expect(sut.state == ViewState<LivePriceViewItem>.loading)
    }

    @Test("load() calls use case once")
    func loadCallsUseCaseOnce() async {
        let anyResult = makeResult()
        let mockUseCase = MockCryptoCurrentPriceUseCase(result: .success(anyResult))
        let sut = CurrentPriceCardViewModel(getCryptoCurrentPriceUseCase: mockUseCase)

        await sut.load()

        #expect(mockUseCase.executeCalls.count == 1)
        let firstCall = mockUseCase.executeCalls.first!
        #expect(firstCall.0 == AppConstants.Coin.bitcoinId)
        #expect(firstCall.1 == AppConstants.Currency.eur)
    }

    @Test("load() transitions to success with mapped PriceRows")
    func loadSuccess() async {
        let anyResult = makeResult()
        let mockUseCase = MockCryptoCurrentPriceUseCase(result: .success(anyResult))
        let sut = CurrentPriceCardViewModel(getCryptoCurrentPriceUseCase: mockUseCase)

        await sut.load()

        guard case .success(let item) = sut.state else {
            Issue.record("Expected .success state after load()")
            return
        }

        #expect(!item.id.uuidString.isEmpty)
        #expect(item.lastUpdated == anyResult.date.hourMinuteSecondFormatted)
        #expect(item.priceText == anyResult.price.currencyFormatted(code: AppConstants.Currency.eur))
    }

    @Test("load() transitions to failure on error")
    func loadFailure() async {
        let anyError = NSError(domain: "any-error", code: 0)
        let mockUseCase = MockCryptoCurrentPriceUseCase(result: .failure(anyError))
        let sut = CurrentPriceCardViewModel(getCryptoCurrentPriceUseCase: mockUseCase)

        await sut.load()

        guard case .failure(let message) = sut.state else {
            Issue.record("Expected .failure state after load() with error")
            return
        }
        #expect(!message.isEmpty)
    }

    @Test("load() sets state to loading before fetching")
    func loadSetsLoadingFirst() async {
        let expectedResult = makeResult()
        let error = NSError(domain: "any-error", code: 0)
        let mockUseCase = MockCryptoCurrentPriceUseCase(result: .failure(error))
        let sut = CurrentPriceCardViewModel(getCryptoCurrentPriceUseCase: mockUseCase)

        await sut.load()

        #expect(sut.state != .loading)

        mockUseCase.result = .success(expectedResult)
        mockUseCase.setDelayMode(.yield)

        let loadTask = Task {
            await sut.load()
        }

        await Task.yield()

        #expect(sut.state == .loading)
        await loadTask.value
        #expect(sut.state != .loading)
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
            try await Task.sleep(nanoseconds: UInt64(duration) * 1_000_000_000)
        case .yield:
            await Task.yield()
        }
    }
}
