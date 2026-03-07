//
//  Untitled.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

protocol CryptoCurrentPriceUseCase {
    func execute(coinId: String, currency: String) async throws -> PricePoint
}
