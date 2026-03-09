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
