//
//  AppCoordinatorTests.swift
//  BitcoinRateDemoTests
//
//  Created by Salar on 3/8/26.
//

import Testing
import Foundation
@testable import BitcoinRateDemo

@MainActor
struct AppCoordinatorTests {

    @Test
    func activeRoute_isNilOnInit() async throws {
        let sut = AppCoordinator()

        #expect(sut.activeRoute == nil)
    }

    @Test
    func navigateToPriceDetails_updatesActiveRoute() async throws {
        let price = CryptoPrice(date: .now, price: 12, coinId: "bitcoin")
        let sut = AppCoordinator()

        sut.navigate(to: .priceDetails(price))

        #expect(sut.activeRoute == .priceDetails(price))
    }

    @Test
    func pop_setsActiveRouteToNil() async throws {
        let price = CryptoPrice(date: .now, price: 12, coinId: "bitcoin")
        let sut = AppCoordinator()
        sut.navigate(to: .priceDetails(price))

        #expect(sut.activeRoute == .priceDetails(price))
        sut.pop()

        #expect(sut.activeRoute == nil)
    }
}
