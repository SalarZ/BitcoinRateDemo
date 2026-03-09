//
//  ProfileCoordinator.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/9/26.
//

import SwiftUI
import Combine

typealias Routable = Hashable & Identifiable

protocol Coordinating: AnyObject {
    associatedtype Route: Routable
    associatedtype Destination: View
    associatedtype RootView: View
    associatedtype Nav: NavigationControlling where Nav.Route == Route

    var navigationController: Nav { get }

    @ViewBuilder @MainActor func coordinate(_ route: Route) -> Destination
    @ViewBuilder @MainActor var rootView: RootView { get }
}

protocol NavigationControlling: ObservableObject {
    associatedtype Route: Routable
    var path: CurrentValueSubject<[Route], Never> { get set }
    var activeRoute: CurrentValueSubject<Route?, Never> { get set }

    func push(_ route: Route)
    func pop()
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

enum ProfileCoordinatorRoute: Routable {
    var id: String { String(describing: self) }

    case priceDetails(CryptoPrice)
    case livePriceDetails(coinId: String)
}

@MainActor
final class ProfileCoordinator: Coordinating, ObservableObject {
    typealias Nav = NavigationController<Route>
    typealias Route = ProfileCoordinatorRoute

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

    @MainActor @ViewBuilder
    var rootView: some View {
        CryptoHistoryView(
            cryptoHistoryItemsViewModel: cryptoHistoryItemsViewModel,
            livePriceCardViewModel: livePriceCardViewModel
        )
    }
}

extension ProfileCoordinator {

    @ViewBuilder @MainActor
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


struct CoordinatedView15<C: Coordinating>: View {
    private var coordinator: C
    @State private var navigationPath: C.Route?

    init(_ coordinator: C) {
        self.coordinator = coordinator
        self.navigationPath = coordinator.navigationController.activeRoute.value
    }

    var body: some View {
        NavigationView {
            coordinator.rootView
                .background(hiddenLink)

        }
        .onChange(of: navigationPath, perform: { value in
            // Synchronize the coordinator's navigation controller path with the SwiftUI navigation path.
            // (e.g., taps back, or swipes to go to the previous page).
            coordinator.navigationController.activeRoute.value = navigationPath
        })
        .onReceive(coordinator.navigationController.activeRoute, perform: { value in
            // Synchronize the SwiftUI navigation path with the coordinator's navigation controller.
            navigationPath = value
        })
    }

    @MainActor @ViewBuilder
    private var hiddenLink: some View {
        NavigationLink(
            isActive: Binding(
                get: {
                    coordinator.navigationController.activeRoute.value != nil
                },
                set: {
                    if !$0 {
                        coordinator.navigationController.pop()
                    }
                }
            ),
            destination: {
                if let activeRoute = coordinator.navigationController.activeRoute.value {
                    coordinator.coordinate(activeRoute)
                } else {
                    EmptyView()
                }
            }, label: { EmptyView() })
        .hidden()
    }
}

@available(iOS 16.0, *)
struct CoordinatedView16<C: Coordinating>: View {
    private var coordinator: C
    @State private var navigationPath: [C.Route]

    init(_ coordinator: C) {
        self.coordinator = coordinator
        self.navigationPath = coordinator.navigationController.path.value
    }


    var body: some View {
        NavigationStack(path: $navigationPath) {
            coordinator.rootView
                .navigationDestination(for: C.Route.self, destination: coordinator.coordinate)

        }
        .onChange(of: navigationPath, perform: { value in
            // Synchronize the coordinator's navigation controller path with the SwiftUI navigation path.
            // (e.g., taps back, or swipes to go to the previous page).
            coordinator.navigationController.path.value = navigationPath
        })
        .onReceive(coordinator.navigationController.path, perform: { value in
            // Synchronize the SwiftUI navigation path with the coordinator's navigation controller.
            navigationPath = value
        })
    }
}

struct CoordinatedView<C: Coordinating>: View {
    private var coordinator: C
    init(_ coordinator: C) {
        self.coordinator = coordinator
    }

    var body: some View {
        if #available(iOS 16.0, *) {
            CoordinatedView16(coordinator)
        } else {
            CoordinatedView15(coordinator)
        }
    }

}
