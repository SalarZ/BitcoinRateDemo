//
//  AppConfiguration.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation

enum AppConfiguration {
    static var coinGeckoAPIKey: String {
        guard let key = Bundle.main.infoDictionary?["COINGECKO_API_KEY"] as? String, !key.isEmpty else {
            fatalError("Missing COINGECKO_API_KEY")
        }
        return key
    }
}
