//
//  BitcoinHistoryViewModelTests.swift
//  BitcoinRateDemoTests
//
//  Created by Salar on 3/7/26.
//

import Foundation
import Testing
@testable import BitcoinRateDemo

@MainActor
struct BitcoinHistoryViewModelTests {

    @Test("initial state is loading")
    func initialStateIsLoading() {
        let sut = BitcoinHistoryViewModel(getCryptoHistoryUseCase: MockCryptoPriceHistoryUseCase())
        guard case .loading = sut.state else {
            Issue.record("Expected .loading initial state")
            return
        }
    }

    @Test("load() calls use case once")
    func loadCallsUseCaseOnce() async {
        let mockUseCase = MockCryptoPriceHistoryUseCase()
        let sut = BitcoinHistoryViewModel(getCryptoHistoryUseCase: mockUseCase)
        
        await sut.load()

        #expect(mockUseCase.executeCalls.count == 1)
        let firstCall = mockUseCase.executeCalls.first!
        #expect(firstCall.0 == AppConstants.Coin.bitcoinId)
        #expect(firstCall.1 == AppConstants.Currency.eur)
        #expect(firstCall.2 == AppConstants.API.priceHistoryDays)
    }

    @Test("load() transitions to success with mapped PriceRows")
    func loadSuccess() async {
        let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
        let points = [
            PricePoint(date: fixedDate, price: 40_000, coinId: "bitcoin"),
            PricePoint(date: fixedDate.addingTimeInterval(86400), price: 41_000, coinId: "bitcoin")
        ]
        let sut = BitcoinHistoryViewModel(
            getCryptoHistoryUseCase: MockCryptoPriceHistoryUseCase(result: .success(points)))

        await sut.load()

        guard case .success(let rows) = sut.state else {
            Issue.record("Expected .success state after load()")
            return
        }
        #expect(rows.count == 2)
        #expect(!rows[0].id.uuidString.isEmpty)
        #expect(rows[0].formattedDate == points[0].date.yearMonthDayFormatted)
        #expect(rows[0].formattedPrice == points[0].price.currencyFormatted(code: AppConstants.Currency.eur))
    }

    @Test("load() transitions to failure on error")
    func loadFailure() async {
        let anyError = NSError(domain: "any-error", code: 0)
        let vm = BitcoinHistoryViewModel(
            getCryptoHistoryUseCase: MockCryptoPriceHistoryUseCase(result: .failure(anyError)))

        await vm.load()

        guard case .failure(let message) = vm.state else {
            Issue.record("Expected .failure state after load() with error")
            return
        }
        #expect(!message.isEmpty)
    }

    @Test("load() sets state to loading before fetching")
    func loadSetsLoadingFirst() async {
        let error = NSError(domain: "any-error", code: 0)
        let mockUseCase = MockCryptoPriceHistoryUseCase(result: .failure(error))
        let sut = BitcoinHistoryViewModel(getCryptoHistoryUseCase: mockUseCase)
        
        await sut.load()

        #expect(sut.state != .loading)

        mockUseCase.result = .success([])
        mockUseCase.setDelayMode(.yield)

        let loadTask = Task {
            await sut.load()
        }

        await Task.yield()

        #expect(sut.state == .loading)
        await loadTask.value
        #expect(sut.state == .success([]))
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

    var result: Result<[PricePoint], Error>

    init(result: Result<[PricePoint], Error> = .success([])) {
        self.result = result
    }

    func execute(coinId: String, currency: String, days: Int) async throws -> [PricePoint] {
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
