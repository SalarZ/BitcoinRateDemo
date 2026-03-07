//
//  CryptoRepositoryError.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation

enum CryptoRepositoryError: Error, LocalizedError, Equatable {
    case noConnection
    case serverError(statusCode: Int)
    case unexpected

    var errorDescription: String? {
        switch self {
        case .noConnection:
            return String(localized: "error.no.connection")
        case .serverError:
            return String(localized: "error.server.error")
        case .unexpected:
            return String(localized: "error.unexpected")
        }
    }
}
