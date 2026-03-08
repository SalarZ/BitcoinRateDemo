//
//  ErrorView.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import SwiftUI

struct ErrorView: View {
    private enum Constants {
        static let spacing: CGFloat = 12
    }

    private let message: String
    private let retryAction: () async throws -> Void

    init(message: String, retryAction: sending @escaping () async throws -> Void) {
        self.message = message
        self.retryAction = retryAction
    }

    var body: some View {
        VStack(spacing: Constants.spacing) {
            Text(String(localized: "error.failed.to.load"))
                .font(.headline)
            Text(message)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Button(String(localized: "action.retry")) {
                Task {
                    try await retryAction()
                }
            }
        }
    }
}

#Preview {
    ErrorView(message: "Error message") { }
}
