//
//  HomeCoordinator.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/9/26.
//

import Combine
import SwiftUI

enum HomeCoordinatorRoute: Routable {
    case priceDetails(CryptoPrice)
    case livePriceDetails(coinId: String)
}

final class HomeCoordinator: Coordinating, ObservableObject {
    typealias Nav = NavigationController<Route>
    typealias Route = HomeCoordinatorRoute

    private let container: DependencyContainer
    let navigationController: NavigationController<Route>

    private(set) lazy var cryptoHistoryItemsViewModel: CryptoHistoryItemsViewModel = {
        CryptoHistoryItemsViewModel(
            getCryptoHistoryUseCase: container.priceHistoryUseCase,
            onSelection: { [weak self] in
                self?.navigationController.push(Route.priceDetails($0))
            }
        )
    }()

    private(set) lazy var livePriceCardViewModel: LivePriceCardViewModel = {
        LivePriceCardViewModel(
            getCryptoCurrentPriceUseCase: container.currentPriceUseCase,
            onSelection: { [weak self] in
                self?.navigationController.push(Route.livePriceDetails(coinId: $0))
            }
        )
    }()

    init(navigationController: NavigationController<Route>,
         container: DependencyContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    @ViewBuilder
    var rootView: some View {
        CryptoHistoryView(
            cryptoHistoryItemsViewModel: cryptoHistoryItemsViewModel,
            livePriceCardViewModel: livePriceCardViewModel
        )
    }
}

extension HomeCoordinator {

    @ViewBuilder
    func coordinate(_ route: Route) -> some View {
        switch route {
        case .priceDetails(let price):
            CryptoDetailsView(viewModel: CryptoDetailsViewModel(loader: { [weak self] in
                guard let self else { throw NSError(domain: "Some Error", code: 0) }
                return try await self.container.priceDetailsUseCase.execute(coinId: price.coinId, date: price.date)
            }))
        case .livePriceDetails(let coinId):
            CryptoDetailsView(viewModel: CryptoDetailsViewModel(loader: { [weak self] in
                guard let self else { throw NSError(domain: "Some Error", code: 0) }
                return try await self.container.livePriceDetailsUseCase.execute(coinId: coinId)
            }))
        }
    }
}
