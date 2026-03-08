//
//  NetworkCryptoPriceRepository.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation
import OSLog

final class NetworkCryptoPriceRepository: CryptoPriceRepository {

    private let networkClient: NetworkClient
    private static let logger = Logger(subsystem: AppConstants.Logging.subsystem,
                                       category: "CryptoPriceRepository")

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func historicalPrices(coinId: String, currency: String, days: Int) async throws -> [PricePoint] {
        let request = APIRequest(
            path: "coins/\(coinId)/market_chart",
            queryItems: [
                .init(name: "vs_currency", value: currency),
                .init(name: "days", value: "\(days)"),
                .init(name: "interval", value: "daily"),
                .init(name: "precision", value: "full")
            ])

        do {
            let marketChart: MarketChartDTO = try await networkClient.send(request)
            return try marketChart.toPricePoints(coinId: coinId)
        } catch {
            throw mapped(error, context: "historicalPrices coinId=\(coinId)")
        }
    }

    func livePrice(coinId: String, currencies: [String]) async throws -> LivePrice {
        let request = APIRequest(
            path: "simple/price",
            queryItems: [
                .init(name: "ids", value: coinId),
                .init(name: "vs_currencies", value: currencies.joined(separator: ",")),
                .init(name: "localization", value: "false"),
                .init(name: "include_last_updated_at", value: "true"),
                .init(name: "precision", value: "full")
            ])

        do {
            let details: CoinGeckoPricesDTO = try await networkClient.send(request)
            return try details.toLivePrice(coinId: coinId)
        } catch {
            throw mapped(error, context: "livePrice coinId=\(coinId)")
        }
    }

    func priceDetails(coinId: String, date: Date) async throws -> PriceDetails {
        let formattedDate = date.apiDateFormat

        let request = APIRequest(
            path: "coins/\(coinId)/history",
            queryItems: [
                .init(name: "date", value: formattedDate),
                .init(name: "localization", value: "false"),
            ])

        do {
            let details: CoinDetailsDTO = try await networkClient.send(request)
            return details.toPriceDetails(for: date)
        } catch {
            throw mapped(error, context: "coinHistoryDetails coinId=\(coinId) date=\(formattedDate)")
        }
    }

    // MARK: - Error mapping

    private func mapped(_ error: Error, context: String) -> Error {
        if error is CryptoRepositoryError { return error }
        let urlError = error as? URLError
        if urlError?.code == .notConnectedToInternet || urlError?.code == .networkConnectionLost {
            Self.logger.warning("No connection — \(context, privacy: .public)")
            return CryptoRepositoryError.noConnection
        }
        Self.logger.error("Request failed — \(context, privacy: .public): \(error.localizedDescription, privacy: .public)")
        return CryptoRepositoryError.unexpected
    }
}

extension Date {
    var apiDateFormat: String {
        if #available(iOS 16.0, *) {
            return formatted(
                .verbatim("\(day: .twoDigits)-\(month: .twoDigits)-\(year: .defaultDigits)" as Date.FormatString,
                          locale: .init(identifier: "en_US_POSIX"),
                          timeZone: .current,
                          calendar: .current))
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            return dateFormatter.string(from: self)
        }
    }
}
