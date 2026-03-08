//
//  AppCoordinator.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/8/26.
//

import Combine

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var activeRoute: AppRoute?

    func navigate(to route: AppRoute) {
        activeRoute = route
    }

    func pop() {
        activeRoute = nil
    }
}

enum AppRoute: Hashable {
    case priceDetails(PricePoint)
}
