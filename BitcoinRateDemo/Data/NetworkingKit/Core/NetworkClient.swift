//
//  NetworkClient.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation
import OSLog

protocol NetworkClient {
    func send<Response: Decodable>(_ request: APIRequest) async throws -> Response
}

final class DefaultNetworkClient: NetworkClient {
    private let httpClient: HTTPClient
    private let baseURL: URL
    private let decoder: JSONDecoder
    private let requestAuthorizer: RequestAuthorizer?
    private let responseValidator: ResponseValidator

    private static let logger = Logger(subsystem: AppConstants.Logging.subsystem,
                                       category: "NetworkClient")

    init(httpClient: HTTPClient,
         baseURL: URL,
         decoder: JSONDecoder = JSONDecoder(),
         requestAuthorizer: RequestAuthorizer? = nil,
         responseValidator: ResponseValidator = StatusCodeValidator()) {
        self.httpClient = httpClient
        self.baseURL = baseURL
        self.decoder = decoder
        self.requestAuthorizer = requestAuthorizer
        self.responseValidator = responseValidator
    }

    func send<Response: Decodable>(_ request: APIRequest) async throws -> Response {
        var requestURL: URL
        if #available(iOS 16.0, *) {
            requestURL = baseURL.appending(path: request.path)
        } else {
            requestURL = baseURL.appendingPathComponent(request.path)
        }

        var components = URLComponents(url: requestURL, resolvingAgainstBaseURL: false)

        if !request.queryItems.isEmpty {
            components?.queryItems = request.queryItems
        }

        guard let url = components?.url else {
            Self.logger.fault(
                "URLComponents failed to produce a valid URL — path: \(request.path, privacy: .public), queryItems: \(request.queryItems.map(\.description).joined(separator: "&"), privacy: .public)"
            )
            throw URLError(.badURL)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        request.headers.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        if request.requiresAuthorization {
            requestAuthorizer?.authorize(&urlRequest)
        }

        let (data, response) = try await httpClient.data(for: urlRequest)
        try responseValidator.validate(data: data, response: response)

        return try decoder.decode(Response.self, from: data)
    }
}
