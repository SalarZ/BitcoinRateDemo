//
//  SimpleEndpoint.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/9/26.
//

import Foundation

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
