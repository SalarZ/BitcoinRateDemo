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
            coordinator.navigationController.activeRoute.value = navigationPath
        })
        .onReceive(coordinator.navigationController.activeRoute, perform: { value in
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
            coordinator.navigationController.path.value = navigationPath
        })
        .onReceive(coordinator.navigationController.path, perform: { value in
            navigationPath = value
        })
    }
}
