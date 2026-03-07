//
//  MarketChartDTO+toPricePoint.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation

extension MarketChartDTO {
    func toPricePoints(coinId: String) throws -> [PricePoint] {
        try prices.map { pair in
            guard pair.count == 2 else {
                throw CryptoRepositoryError.mapping(.unexpectedValue(field: "prices"))
            }
            let timestampMs = pair[0]
            let price = pair[1]
            let date = Date(timeIntervalSince1970: timestampMs / 1000.0)
            return PricePoint(date: date, price: price, coinId: coinId)
        }
    }
}
