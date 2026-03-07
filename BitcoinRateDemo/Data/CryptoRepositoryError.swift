//
//  CryptoRepositoryError.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation

enum MappingError: Error, LocalizedError, Equatable {
    case missingRequiredField(field: String)
    case unexpectedValue(field: String)

    var errorDescription: String? {
        switch self {
        case .missingRequiredField(let field):
            return String(localized: "error.mapping.missingRequiredField \(field)")
        case .unexpectedValue(let field):
            return String(localized: "error.mapping.unexpectedValue \(field)")
        }
    }
}

enum CryptoRepositoryError: Error, LocalizedError, Equatable {
    case noConnection
    case serverError(statusCode: Int)
    case unexpected
    case mapping(MappingError)

    var errorDescription: String? {
        switch self {
        case .noConnection:
            return String(localized: "error.no.connection")
        case .serverError:
            return String(localized: "error.server.error")
        case .unexpected:
            return String(localized: "error.unexpected")
        case .mapping(let error):
            return error.localizedDescription
        }
    }
}
