//
//  RootView.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/8/26.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        CoordinatedView(ProfileCoordinator(navigationController: NavigationController(), container: container))
    }

//    @ViewBuilder
//    private var hiddenLink: some View {
//        NavigationLink(
//            isActive: Binding(
//                get: { coordinator.activeRoute != nil },
//                set: { if !$0 { coordinator.pop() }}
//            ),
//            destination: {
//                destinationView
//            }, label: { EmptyView() })
//        .hidden()
//    }
//
//    @ViewBuilder
//    private var destinationView: some View {
//        switch coordinator.activeRoute {
//        case .priceDetails(let price):
//            CryptoDetailsView(viewModel: CryptoDetailsViewModel(loader: {
//                try await container.priceDetailsUseCase.execute(coinId: price.coinId, date: price.date)
//            }))
//        case .livePriceDetails(let coinId):
//            CryptoDetailsView(viewModel: CryptoDetailsViewModel(loader: {
//                try await container.livePriceDetailsUseCase.execute(coinId: coinId)
//            }))
//        case .none:
//            EmptyView()
//        }
//    }
}

#Preview {
    let container = DependencyContainer()
    return RootView()
        .environmentObject(container)
        .environmentObject(container.appCoordinator)
}
