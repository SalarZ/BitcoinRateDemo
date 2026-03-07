//
//  CryptoPriceRepository.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

protocol CryptoPriceRepository {
    func historicalPrices(coinId: String, currency: String, days: Int) async throws -> [PricePoint]
    func livePrice(coinId: String, currencies: [String]) async throws -> LivePrice
}
