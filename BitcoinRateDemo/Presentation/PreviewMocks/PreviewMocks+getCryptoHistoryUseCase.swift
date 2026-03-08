//
//  PreviewMocks+getCryptoHistoryUseCase.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/8/26.
//

import Foundation

#if DEBUG
extension PreviewMocks {
    static func getCryptoHistoryUseCase(
        delayDuration: TimeInterval = 1,
        mode: MockCryptoHistoryUseCase.Mode = .success
    ) -> MockCryptoHistoryUseCase {
        return MockCryptoHistoryUseCase(delayDuration: delayDuration, mode: mode)
    }

    struct MockCryptoHistoryUseCase: CryptoPriceHistoryUseCase {

        enum Mode {
            case success, failure
        }

        private let delayDuration: TimeInterval
        private let mode: Mode

        init(delayDuration: TimeInterval = 1.0, mode: Mode = .success) {
            self.delayDuration = delayDuration
            self.mode = mode
        }

        func execute(coinId: String, currency: String, days: Int) async throws -> [CryptoPrice] {
            try? await Task.sleep(seconds: delayDuration)
            switch mode {
            case .success:
                return (0..<days).map { i in
                    CryptoPrice(date: makeDate(daysAgo: i), price: Double(i), coinId: "bitcoin")
                }
            case .failure:
                throw NSError(domain: "", code: 0, userInfo: nil)
            }
        }

        private func makeDate(daysAgo: Int) -> Date {
            Calendar.current.date(byAdding: .day, value: -daysAgo, to: .now)!
        }

    }
}
#endif
