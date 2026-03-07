//
//  CoinGeckoPricesDTO+toCoinPriceDetails.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

extension CoinGeckoPricesDTO {
    func toCoinPriceDetails(coinId: String) throws -> CoinPriceDetails {
        guard let coinDetail = self[coinId] else {
            throw CryptoRepositoryError.mapping(.missingRequiredField(field: coinId))
        }
        return CoinPriceDetails(name: coinId,
                         prices: coinDetail.prices,
                         lastUpdate: coinDetail.lastUpdatedAt)
    }
}
