//
//  CoordinatedView.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/9/26.
//

import SwiftUI
import Combine

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

struct CoordinatedView15<C: Coordinating>: View {
    private var coordinator: C
    @StateObject var navigationController: C.Nav

    init(_ coordinator: C) {
        self.coordinator = coordinator
        _navigationController = StateObject(wrappedValue: coordinator.navigationController)
    }

    var body: some View {
        NavigationView {
            coordinator.rootView
                .background(hiddenLink)
        }
    }

    @MainActor @ViewBuilder
    private var hiddenLink: some View {
        NavigationLink(
            isActive: Binding(
                get: {
                    return navigationController.activeRoute != nil
                },
                set: {
                    if !$0 {
                        navigationController.pop()
                    }
                }
            ),
            destination: {
                if let activeRoute = navigationController.activeRoute {
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
    @StateObject var navigationController: C.Nav

    init(_ coordinator: C) {
        self.coordinator = coordinator
        _navigationController = StateObject(wrappedValue: coordinator.navigationController)
    }

    var body: some View {
        NavigationStack(path: $navigationController.path) {
            coordinator.rootView
                .navigationDestination(for: C.Route.self, destination: coordinator.coordinate)
        }
    }
}
