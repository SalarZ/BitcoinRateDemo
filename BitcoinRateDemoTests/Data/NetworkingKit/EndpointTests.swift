//
//  EndpointTests.swift
//  BitcoinRateDemoTests
//
//  Created by Salar on 3/7/26.
//

import Testing
import Foundation
@testable import BitcoinRateDemo

@Suite("CoinEndpoint Tests")
struct CoinEndpointTests {

    @Test("history builds correct path")
    func historyPath() {
        let endpoint = CoinEndpoint.history(
            .init(coinId: "bitcoin", date: "10-03-2026")
        )

        #expect(endpoint.path == "coins/bitcoin/history")
    }

    @Test("marketChart builds correct path")
    func marketChartPath() {
        let endpoint = CoinEndpoint.marketChart(
            .init(coinId: "ethereum", currency: "usd", days: 30)
        )

        #expect(endpoint.path == "coins/ethereum/market_chart")
    }

    @Test("CoinEndpoint method is GET")
    func coinEndpointMethod() {
        let history = CoinEndpoint.history(
            .init(coinId: "bitcoin", date: "10-03-2026")
        )
        let marketChart = CoinEndpoint.marketChart(
            .init(coinId: "ethereum", currency: "usd", days: 30)
        )

        #expect(history.method == .get)
        #expect(marketChart.method == .get)
    }

    @Test("history query items are correct")
    func historyQueryItems() {
        let endpoint = CoinEndpoint.history(
            .init(coinId: "bitcoin", date: "10-03-2026")
        )

        #expect(
            endpoint.queryItems == [
                URLQueryItem(name: "date", value: "10-03-2026"),
                URLQueryItem(name: "localization", value: "false")
            ]
        )
    }

    @Test("marketChart query items are correct")
    func marketChartQueryItems() {
        let endpoint = CoinEndpoint.marketChart(
            .init(coinId: "ethereum", currency: "usd", days: 30)
        )

        #expect(
            endpoint.queryItems == [
                URLQueryItem(name: "vs_currency", value: "usd"),
                URLQueryItem(name: "days", value: "30"),
                URLQueryItem(name: "interval", value: "daily"),
                URLQueryItem(name: "precision", value: "full")
            ]
        )
    }

    @Test("CoinEndpoint headers are empty")
    func coinEndpointHeaders() {
        let endpoint = CoinEndpoint.history(
            .init(coinId: "bitcoin", date: "10-03-2026")
        )

        #expect(endpoint.headers.isEmpty)
    }

    @Test("CoinEndpoint requires authorization")
    func coinEndpointRequiresAuthorization() {
        let endpoint = CoinEndpoint.marketChart(
            .init(coinId: "ethereum", currency: "usd", days: 30)
        )

        #expect(endpoint.requiresAuthorization)
    }
}

@Suite("SimpleEndpoint Tests")
struct SimpleEndpointTests {

    @Test("price builds correct path")
    func pricePath() {
        let endpoint = SimpleEndpoint.price(
            .init(coinId: "bitcoin", currencies: ["usd", "eur"])
        )

        #expect(endpoint.path == "simple/price")
    }

    @Test("SimpleEndpoint method is GET")
    func simpleEndpointMethod() {
        let endpoint = SimpleEndpoint.price(
            .init(coinId: "bitcoin", currencies: ["usd", "eur"])
        )

        #expect(endpoint.method == .get)
    }

    @Test("price query items are correct")
    func priceQueryItems() {
        let endpoint = SimpleEndpoint.price(
            .init(coinId: "bitcoin", currencies: ["usd", "eur"])
        )

        #expect(
            endpoint.queryItems == [
                URLQueryItem(name: "ids", value: "bitcoin"),
                URLQueryItem(name: "vs_currencies", value: "usd,eur"),
                URLQueryItem(name: "localization", value: "false"),
                URLQueryItem(name: "include_last_updated_at", value: "true"),
                URLQueryItem(name: "precision", value: "full")
            ]
        )
    }

    @Test("price joins currencies with commas")
    func priceQueryItemsJoinsCurrencies() {
        let endpoint = SimpleEndpoint.price(
            .init(coinId: "solana", currencies: ["usd", "eur", "jpy"])
        )

        let vsCurrencies = endpoint.queryItems.first { $0.name == "vs_currencies" }?.value
        #expect(vsCurrencies == "usd,eur,jpy")
    }

    @Test("SimpleEndpoint headers are empty")
    func simpleEndpointHeaders() {
        let endpoint = SimpleEndpoint.price(
            .init(coinId: "bitcoin", currencies: ["usd"])
        )

        #expect(endpoint.headers.isEmpty)
    }

    @Test("SimpleEndpoint requires authorization")
    func simpleEndpointRequiresAuthorization() {
        let endpoint = SimpleEndpoint.price(
            .init(coinId: "bitcoin", currencies: ["usd"])
        )

        #expect(endpoint.requiresAuthorization)
    }
}
