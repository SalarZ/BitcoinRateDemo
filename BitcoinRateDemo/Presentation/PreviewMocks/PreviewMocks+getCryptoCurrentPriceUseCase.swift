//
//  PreviewMocks+getCryptoCurrentPriceUseCase.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/8/26.
//

import Foundation

#if DEBUG
extension PreviewMocks {
    static func getCryptoCurrentPriceUseCase(
        delayDuration: TimeInterval = 1,
        mode: MockGetCryptoCurrentPriceUseCase.Mode = .success
    ) -> CryptoCurrentPriceUseCase {
        return MockGetCryptoCurrentPriceUseCase(delayDuration: delayDuration, mode: mode)
    }

    final class MockGetCryptoCurrentPriceUseCase: CryptoCurrentPriceUseCase {
        enum Mode {
            case success, failure, successOnce
        }

        private var executeCallsCount = 0
        private let delayDuration: TimeInterval
        private let mode: Mode

        init(delayDuration: TimeInterval = 1, mode: Mode = .success) {
            self.delayDuration = delayDuration
            self.mode = mode
        }

        func execute(coinId: String, currency: String) async throws -> CryptoPrice {
            try? await Task.sleep(seconds: delayDuration)
            switch mode {
            case .success:
                return CryptoPrice(date: Date.now, price: 1234.1234, coinId: "bitcoin")
            case .failure:
                throw NSError(domain: "Server error", code: 0)
            case .successOnce:
                executeCallsCount += 1
                if executeCallsCount > 1 {
                    throw NSError(domain: "Server error", code: 0)
                } else {
                    return CryptoPrice(date: Date.now, price: 1234.1234, coinId: "bitcoin")
                }
            }
        }
    }
}
#endif
