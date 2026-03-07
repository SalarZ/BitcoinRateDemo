//
//  CryptoPriceHistoryUseCase.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation

protocol CryptoPriceHistoryUseCase {
    func execute(coinId: String, currency: String, days: Int) async throws -> [PricePoint]
}
