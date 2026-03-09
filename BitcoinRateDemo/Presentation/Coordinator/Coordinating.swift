//
//  Coordinating.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/9/26.
//

import SwiftUI
import Combine

typealias Routable = Hashable

protocol NavigationControlling: ObservableObject {
    associatedtype Route: Routable
    var path: [Route] { get set }

    func push(_ route: Route)
    func pop()
}

@MainActor
protocol Coordinating {
    associatedtype Route: Routable
    associatedtype Destination: View
    associatedtype RootView: View
    associatedtype Nav: NavigationControlling where Nav.Route == Route

    var navigationController: Nav { get }

    @ViewBuilder func coordinate(_ route: Route) -> Destination
    @ViewBuilder var rootView: RootView { get }
}

final class NavigationController<Route: Routable>: NavigationControlling {
    @Published var path: [Route] = []

    func push(_ route: Route) {
        path.append(route)
    }

    func pop() {
        _ = path.popLast()
    }
}
