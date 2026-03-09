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
    var activeRoute: Route? { get set }

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
    @Published var activeRoute: Route? = nil

    func push(_ route: Route) {
        if #available(iOS 16, *) {
            path.append(route)
        } else {
            activeRoute = route
        }
    }

    func pop() {
        if #available(iOS 16, *) {
            _ = path.popLast()
        } else {
            activeRoute = nil
        }
    }
}
