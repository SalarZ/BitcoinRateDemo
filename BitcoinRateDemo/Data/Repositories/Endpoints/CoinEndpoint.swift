//
//  CoinEndpoint.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/9/26.
//

import Foundation

enum CoinEndpoint: Endpoint {
    struct HistoryParams {
        let coinId: String
        let date: String
    }

    struct MarketChartParams {
        let coinId: String
        let currency: String
        let days: Int
    }

    case history(HistoryParams)
    case marketChart(MarketChartParams)

    var path: String {
        switch self {
        case .history(let param):
            "coins/\(param.coinId)/history"
        case .marketChart(let param):
            "coins/\(param.coinId)/market_chart"
        }
    }

    var method: HTTPMethod {
        .get
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .history(let param):
            return [
                URLQueryItem(name: "date", value: param.date),
                URLQueryItem(name: "localization", value: "false"),
            ]
        case .marketChart(let param):
            return [
                URLQueryItem(name: "vs_currency", value: param.currency),
                URLQueryItem(name: "days", value: "\(param.days)"),
                URLQueryItem(name: "interval", value: "daily"),
                URLQueryItem(name: "precision", value: "full")
            ]
        }
    }

    var headers: [String : String] {
        [:]
    }

    var requiresAuthorization: Bool {
        true
    }
}
