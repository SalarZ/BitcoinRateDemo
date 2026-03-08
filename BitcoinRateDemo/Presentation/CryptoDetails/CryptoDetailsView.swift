//
//  CryptoDetailsView.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import SwiftUI

struct CryptoDetailsView: View {
    private enum Constants {
        static let spacing: CGFloat = 16
        static let cornerRadius: CGFloat = 8
    }

    @StateObject private var viewModel: CryptoDetailsViewModel

    init(viewModel: CryptoDetailsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: Constants.spacing) {
            switch viewModel.state {
            case .loading:
                ProgressView()
            case .loaded(let details):
                Text(String(localized: "details.last.update \(details.date)"))
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Group {
                    makeRow(currency: AppConstants.Currency.eur.uppercased(), price: details.eurPrice)
                    makeRow(currency: AppConstants.Currency.usd.uppercased(), price: details.usdPrice)
                    makeRow(currency: AppConstants.Currency.gbp.uppercased(), price: details.gbpPrice)
                }
                .padding()
                .background(.thickMaterial)
                .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
            case .failure(let error):
                ErrorView(message: error) {
                    await viewModel.load()
                }
                .padding()
            }

            Spacer()
        }
        .padding()
        .navigationTitle(String(localized: "details.nav.title"))
        .task {
            await viewModel.load()
        }
    }

    private func makeRow(currency: String, price: String) -> some View {
        HStack {
            BadgeView(text: currency)
            Spacer()
            Text(price)
        }
    }
}

#Preview {
    CryptoDetailsView(viewModel: CryptoDetailsViewModel(loader: {
        CryptoDetails(name: "bitcoin",
                     eurPrice: 1_000.21,
                     usdPrice: 1_200.21,
                     gbpPrice: 802,
                     lastUpdate: Date.now)
    }))
}
