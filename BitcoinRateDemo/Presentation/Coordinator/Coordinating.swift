//
//  Coordinating.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/9/26.
//

import SwiftUI
import Combine

typealias Routable = Hashable & Identifiable

protocol NavigationControlling: ObservableObject {
    associatedtype Route: Routable
    var path: CurrentValueSubject<[Route], Never> { get set }
    var activeRoute: CurrentValueSubject<Route?, Never> { get set }

    func push(_ route: Route)
    func pop()
}

protocol Coordinating: AnyObject {
    associatedtype Route: Routable
    associatedtype Destination: View
    associatedtype RootView: View
    associatedtype Nav: NavigationControlling where Nav.Route == Route

    var navigationController: Nav { get }

    @ViewBuilder @MainActor func coordinate(_ route: Route) -> Destination
    @ViewBuilder @MainActor var rootView: RootView { get }
}

final class NavigationController<Route: Routable>: NavigationControlling {
    var path: CurrentValueSubject<[Route], Never> = .init([])
    var activeRoute: CurrentValueSubject<Route?, Never> = .init(nil)

    func push(_ route: Route) {
        if #available(iOS 16, *) {
            path.value.append(route)
        } else {
            activeRoute.value = route
        }
    }

    func pop() {
        if #available(iOS 16, *) {
            _ = path.value.popLast()
        } else {
            activeRoute.value = nil
        }
    }
}
