//
//  AppConfiguration.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation

struct AppConfiguration {
    enum Keys {
        static let apiKey = "COINGECKO_API_KEY"
    }

    static var coinGeckoAPIKey: String {
        guard let key = Bundle.main.infoDictionary?[Keys.apiKey] as? String, !key.isEmpty else {
            fatalError("Missing COINGECKO_API_KEY")
        }
        return key
    }
}
