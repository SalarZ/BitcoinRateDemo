//
//  Endpoint.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation

protocol Endpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem] { get }
    var headers: [String: String] { get }
    var requiresAuthorization: Bool { get }
}

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

enum SimpleEndpoint: Endpoint {
    struct PriceParam {
        let coinId: String
        let currencies: [String]
    }

    case price(PriceParam)

    var path: String {
        switch self {
        case .price:
            return "simple/price"
        }
    }

    var method: HTTPMethod {
        .get
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .price(let param):
            return [
                URLQueryItem(name: "ids", value: param.coinId),
                URLQueryItem(name: "vs_currencies", value: param.currencies.joined(separator: ",")),
                URLQueryItem(name: "localization", value: "false"),
                URLQueryItem(name: "include_last_updated_at", value: "true"),
                URLQueryItem(name: "precision", value: "full")
            ]
        }
    }

    var headers: [String : String] { [:] }

    var requiresAuthorization: Bool { true }

}
