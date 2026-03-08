//
//  NetworkCryptoPriceRepositoryTests.swift
//  BitcoinRateDemoTests
//
//  Created by Salar on 3/7/26.
//

import Testing
import Foundation
@testable import BitcoinRateDemo

struct NetworkCryptoPriceRepositoryTests {

    // MARK: - historicalPrices
    @Test("historicalPrices returns converted prices and builds correct request")
    func historicalPrices_success() async throws {
        let expectedCoinId = "bitcoin"
        let expectedCurrency = "usd"
        let expectedDays = 2
        let dto = MarketChartDTO(prices: [[123, 100.0], [1234, 110.0]])
        let client = MockNetworkClient()
        let sut = NetworkCryptoPriceRepository(networkClient: client)

        client.result = dto

        let result = try await sut.historicalPrices(coinId: expectedCoinId,
                                                    currency: expectedCurrency,
                                                    days: expectedDays)

        #expect(client.sendCalls.count == 1)
        let request = try #require(client.sendCalls.first)

        #expect(request.path == "coins/\(expectedCoinId)/market_chart")
        #expect(request.queryItems.count == 4)
        #expect(request.queryItems.contains(URLQueryItem(name: "vs_currency", value: expectedCurrency)))
        #expect(request.queryItems.contains(URLQueryItem(name: "days", value: "\(expectedDays)")))
        #expect(request.queryItems.contains(URLQueryItem(name: "interval", value: "daily")))
        #expect(request.queryItems.contains(URLQueryItem(name: "precision", value: "full")))
        let expected = try dto.toCryptoPrice(coinId: expectedCoinId)
        #expect(result == expected)
    }

    @Test("historicalPrices passes through CryptoRepositoryError unchanged")
    func historicalPrices_passthroughCryptoRepositoryError() async {
        let client = MockNetworkClient()
        client.error = CryptoRepositoryError.noConnection

        let sut = NetworkCryptoPriceRepository(networkClient: client)

        await #expect(throws: CryptoRepositoryError.noConnection) {
            try await sut.historicalPrices(coinId: "bitcoin", currency: "usd", days: 7)
        }
    }

    @Test("historicalPrices throw unexpectedValue")
    func historicalPrices_throwUnexpectedValueError() async {
        let client = MockNetworkClient()
        let dto = MarketChartDTO(prices: [[123, 100.0], [110.0]])
        client.result = dto

        let sut = NetworkCryptoPriceRepository(networkClient: client)

        await #expect(throws: CryptoRepositoryError.mapping(.unexpectedValue(field: "prices"))) {
            try await sut.historicalPrices(coinId: "bitcoin", currency: "usd", days: 7)
        }
    }

    @Test("historicalPrices maps URLError.notConnectedToInternet to noConnection")
    func historicalPrices_mapsNotConnectedToInternet() async {
        let client = MockNetworkClient()
        client.error = URLError(.notConnectedToInternet)

        let sut = NetworkCryptoPriceRepository(networkClient: client)

        await #expect(throws: CryptoRepositoryError.noConnection) {
            _ = try await sut.historicalPrices(coinId: "bitcoin", currency: "usd", days: 7)
        }
    }

    @Test("historicalPrices maps URLError.networkConnectionLost to noConnection")
    func historicalPrices_mapsNetworkConnectionLost() async {
        let client = MockNetworkClient()
        client.error = URLError(.networkConnectionLost)

        let sut = NetworkCryptoPriceRepository(networkClient: client)

        await #expect(throws: CryptoRepositoryError.noConnection) {
            _ = try await sut.historicalPrices(coinId: "bitcoin", currency: "usd", days: 7)
        }
    }

    @Test("historicalPrices maps non-network errors to unexpected")
    func historicalPrices_mapsUnexpectedError() async {
        let client = MockNetworkClient()
        client.error = NSError(domain: "any-error", code: 0)

        let sut = NetworkCryptoPriceRepository(networkClient: client)

        await #expect(throws: CryptoRepositoryError.unexpected) {
            _ = try await sut.historicalPrices(coinId: "bitcoin", currency: "usd", days: 7)
        }
    }

    // MARK: - livePrice

    @Test("livePrice returns converted details and builds correct request")
    func livePrice_success() async throws {
        let expectedCoinId = "bitcoin"
        let expectedCurrencies = ["eur"]
        let client = MockNetworkClient()
        let sut = NetworkCryptoPriceRepository(networkClient: client)
        let dto: CoinGeckoPricesDTO = [
            "bitcoin": CoinPriceDTO(prices: ["eur": 1231.312],
                                    lastUpdatedAt: Date())
        ]

        client.result = dto

        let result = try await sut.livePrice(coinId: expectedCoinId, currencies: expectedCurrencies)

        #expect(client.sendCalls.count == 1)
        let request = try #require(client.sendCalls.first)

        #expect(request.path == "simple/price")
        #expect(request.queryItems.count == 5)
        #expect(request.queryItems.contains(URLQueryItem(name: "ids", value: expectedCoinId)))
        #expect(request.queryItems.contains(URLQueryItem(name: "vs_currencies", value: "eur")))
        #expect(request.queryItems.contains(URLQueryItem(name: "localization", value: "false")))
        #expect(request.queryItems.contains(URLQueryItem(name: "include_last_updated_at", value: "true")))
        #expect(request.queryItems.contains(URLQueryItem(name: "precision", value: "full")))
        let expected = try dto.toLivePrice(coinId: expectedCoinId)
        #expect(result == expected)
    }

    @Test("livePrice throw unexpectedValue")
    func livePrice_throwUnexpectedValueError() async {
        let expectedCoinId = "bitcoin"
        let expectedCurrencies = ["eur"]
        let client = MockNetworkClient()
        let dto: CoinGeckoPricesDTO = [
            "invalid": CoinPriceDTO(prices: ["eur": 1231.312],
                                    lastUpdatedAt: Date())
        ]

        client.result = dto

        let sut = NetworkCryptoPriceRepository(networkClient: client)

        await #expect(throws: CryptoRepositoryError.mapping(.missingRequiredField(field: expectedCoinId))) {
            try await sut.livePrice(coinId: expectedCoinId, currencies: expectedCurrencies)
        }
    }

    @Test("livePrice passes through CryptoRepositoryError unchanged")
    func livePrice_passthroughCryptoRepositoryError() async {
        let client = MockNetworkClient()
        client.error = CryptoRepositoryError.unexpected

        let sut = NetworkCryptoPriceRepository(networkClient: client)

        await #expect(throws: CryptoRepositoryError.unexpected) {
            _ = try await sut.livePrice(coinId: "bitcoin", currencies: ["usd"])
        }
    }

    @Test("livePrice maps connection errors to noConnection")
    func livePrice_mapsConnectionErrors() async {
        for code in [URLError.Code.notConnectedToInternet, .networkConnectionLost] {
            let client = MockNetworkClient()
            client.error = URLError(code)

            let sut = NetworkCryptoPriceRepository(networkClient: client)

            await #expect(throws: CryptoRepositoryError.noConnection) {
                _ = try await sut.livePrice(coinId: "bitcoin", currencies: ["usd"])
            }
        }
    }

    @Test("livePrice maps non-network errors to unexpected")
    func livePrice_mapsUnexpectedError() async {
        let client = MockNetworkClient()
        client.error = NSError(domain: "any-error", code: 0)

        let sut = NetworkCryptoPriceRepository(networkClient: client)

        await #expect(throws: CryptoRepositoryError.unexpected) {
            _ = try await sut.livePrice(coinId: "bitcoin", currencies: ["usd"])
        }
    }

    // MARK: - priceDetails
    @Test("priceDetails returns converted details and builds correct request")
    func priceDetails_success() async throws {
        let coinId = "bitcoin"
        let date = Date.now
        let client = MockNetworkClient()
        let sut = NetworkCryptoPriceRepository(networkClient: client)
        let dto = CoinDetailsDTO(
            name: coinId,
            marketData: MarketDataDTO(
                currentPrice: ["eur": 1_000,
                               "usd": 1_200,
                               "gbp": 800]
            )
        )

        client.result = dto

        let result = try await sut.priceDetails(coinId: coinId, date: date)

        #expect(client.sendCalls.count == 1)
        let request = try #require(client.sendCalls.first)

        #expect(request.path == "coins/bitcoin/history")
        #expect(request.queryItems.count == 2)
        #expect(request.queryItems.contains(URLQueryItem(name: "date", value: date.apiDateFormat)))
        #expect(request.queryItems.contains(URLQueryItem(name: "localization", value: "false")))
        let expected = dto.toPriceDetails(for: date)
        #expect(result == expected)
    }

    @Test("priceDetails passes through CryptoRepositoryError unchanged")
    func priceDetails_passthroughCryptoRepositoryError() async {
        let client = MockNetworkClient()
        client.error = CryptoRepositoryError.unexpected

        let sut = NetworkCryptoPriceRepository(networkClient: client)

        await #expect(throws: CryptoRepositoryError.unexpected) {
            _ = try await sut.priceDetails(coinId: "bitcoin", date: Date.now)
        }
    }

    @Test("priceDetails maps connection errors to noConnection")
    func priceDetails_mapsConnectionErrors() async {
        let coinId = "bitcoin"
        let date = Date.now
        for code in [URLError.Code.notConnectedToInternet, .networkConnectionLost] {
            let client = MockNetworkClient()
            client.error = URLError(code)

            let sut = NetworkCryptoPriceRepository(networkClient: client)

            await #expect(throws: CryptoRepositoryError.noConnection) {
                _ = try await sut.priceDetails(coinId: coinId, date: date)
            }
        }
    }

    @Test("priceDetails maps non-network errors to unexpected")
    func priceDetails_mapsUnexpectedError() async {
        let coinId = "bitcoin"
        let date = Date.now
        let client = MockNetworkClient()
        client.error = NSError(domain: "any-error", code: 0)

        let sut = NetworkCryptoPriceRepository(networkClient: client)

        await #expect(throws: CryptoRepositoryError.unexpected) {
            _ = try await sut.priceDetails(coinId: coinId, date: date)
        }
    }
}

private final class MockNetworkClient: NetworkClient {
    var result: Any = ()
    var error: Error?
    var sendCalls: [APIRequest] = []

    func send<Response: Decodable>(_ request: APIRequest) async throws -> Response {
        sendCalls.append(request)
        if let error = error { throw error }
        guard let typedResult = result as? Response else {
            throw URLError(.unknown)
        }
        return typedResult
    }
}
