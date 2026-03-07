//
//  ResponseValidator.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation
import OSLog

protocol ResponseValidator {
    func validate(data: Data, response: URLResponse) throws
}

struct StatusCodeValidator: ResponseValidator {
    private static let logger = Logger(subsystem: AppConstants.Logging.subsystem,
                                       category: "NetworkClient")
    private let validRange: ClosedRange<Int>

    init(validRange: ClosedRange<Int> = 200...299) {
        self.validRange = validRange
    }

    func validate(data: Data, response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else { return }
        let statusCode = httpResponse.statusCode
        guard validRange.contains(statusCode) else {
            Self.logger.error("HTTP \(statusCode) for \(httpResponse.url?.path ?? "unknown", privacy: .public)")
            throw CryptoRepositoryError.serverError(statusCode: statusCode)
        }
    }
}
