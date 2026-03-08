//
//  CoinDetailsDTO.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation

struct CoinDetailsDTO: Decodable {
    let name: String
    let marketData: MarketDataDTO

    init(name: String, marketData: MarketDataDTO) {
        self.name = name
        self.marketData = marketData
    }

    enum CodingKeys: String, CodingKey {
        case name
        case marketData = "market_data"
    }
}

// MARK: - MarketData
struct MarketDataDTO: Decodable {
    let currentPrice: [String: Double]

    init(currentPrice: [String : Double]) {
        self.currentPrice = currentPrice
    }

    enum CodingKeys: String, CodingKey {
        case currentPrice = "current_price"
    }
}

extension CoinDetailsDTO {
    func toPriceDetails(for date: Date) -> CryptoDetails {
        return CryptoDetails(name: name,
                            eurPrice: marketData.currentPrice["eur"],
                            usdPrice: marketData.currentPrice["usd"],
                            gbpPrice: marketData.currentPrice["gbp"],
                            lastUpdate: date)
    }
}
