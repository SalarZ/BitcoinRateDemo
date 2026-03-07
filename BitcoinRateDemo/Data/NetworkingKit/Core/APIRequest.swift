//
//  APIRequest.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation

struct APIRequest {
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]
    let headers: [String: String]
    let requiresAuthorization: Bool

    init(path: String,
         method: HTTPMethod = .get,
         queryItems: [URLQueryItem] = [],
         headers: [String: String] = [:],
         requiresAuthorization: Bool = true) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.headers = headers
        self.requiresAuthorization = requiresAuthorization
    }
}
