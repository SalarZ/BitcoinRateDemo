//
//  AppConstants.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation

enum AppConstants {

    enum Coin {
        static let bitcoinId = "bitcoin"
    }

    enum Currency {
        static let eur = "eur"
        static let usd = "usd"
        static let gbp = "gbp"
        static let detailCurrencies = [eur, usd, gbp]
    }

    enum API {
        static let baseURL = URL(string: "https://api.coingecko.com/api/v3/")!
        static let priceHistoryDays = 14
    }

    enum Logging {
        static let subsystem = Bundle.main.bundleIdentifier ?? "BitcoinTest"
    }
}
