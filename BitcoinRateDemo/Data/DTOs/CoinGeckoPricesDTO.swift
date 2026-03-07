//
//  CoinGeckoPricesDTO.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation

typealias CoinGeckoPricesDTO = [String: CoinPriceDTO]

struct CoinPriceDTO: Decodable {
    let prices: [String: Double]
    let lastUpdatedAt: Date

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKey.self)

        var prices: [String: Double] = [:]
        var lastUpdatedAt: Double?

        for key in container.allKeys {
            switch key.stringValue {
            case "last_updated_at":
                lastUpdatedAt = try container.decode(Double.self, forKey: key)
            default:
                prices[key.stringValue] = try container.decode(Double.self, forKey: key)
            }
        }

        guard let lastUpdatedAt else {
            throw DecodingError.keyNotFound(
                DynamicCodingKey(stringValue: "last_updated_at")!,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Missing last_updated_at"
                )
            )
        }

        self.prices = prices
        let date = Date(timeIntervalSince1970: lastUpdatedAt)
        self.lastUpdatedAt = date
    }
}

private struct DynamicCodingKey: CodingKey {
    let stringValue: String
    let intValue: Int? = nil

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        return nil
    }
}
