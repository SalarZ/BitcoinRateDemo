//
//  CryptoPriceRepository.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation

protocol CryptoPriceRepository {
    func historicalPrices(coinId: String, currency: String, days: Int) async throws -> [CryptoPrice]
    func livePrice(coinId: String, currencies: [String]) async throws -> LivePrice
    func priceDetails(coinId: String, date: Date) async throws -> CryptoDetails
}
