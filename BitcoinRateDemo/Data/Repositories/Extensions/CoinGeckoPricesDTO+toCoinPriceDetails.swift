//
//  CoinGeckoPricesDTO+toCoinPriceDetails.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

extension CoinGeckoPricesDTO {
    func toLivePrice(coinId: String) throws -> LivePrice {
        guard let coinDetail = self[coinId] else {
            throw CryptoRepositoryError.mapping(.missingRequiredField(field: coinId))
        }
        return LivePrice(name: coinId,
                         prices: coinDetail.prices,
                         lastUpdate: coinDetail.lastUpdatedAt)
    }
}
