//
//  RequestAuthorizer.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation

protocol RequestAuthorizer {
    func authorize(_ request: inout URLRequest)
}

struct APIKeyAuthorizer: RequestAuthorizer {
    private let apiKey: String

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func authorize(_ request: inout URLRequest) {
        request.setValue(apiKey, forHTTPHeaderField: "x-cg-demo-api-key")
    }
}
