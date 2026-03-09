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
            RecursiveNavLink(
                path: $navigationController.path,
                index: 0,
                content: AnyView(coordinator.rootView),
                buildDestination: { active in
                    AnyView(coordinator.coordinate(active))
                })
        }
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

private struct RecursiveNavLink<Route: Routable>: View {
    @Binding var path: [Route]
    let index: Int
    let content: AnyView
    let buildDestination: (Route) -> AnyView

    private var isActive: Binding<Bool> {
        Binding(
            get: { path.count > index },
            set: { isActive in
                if !isActive, path.count > index {
                    path.removeLast(path.count - index)
                }
            }
        )
    }

    var body: some View {
        content
            .background(
                NavigationLink(
                    isActive: isActive,
                    destination: {
                        if path.count > index {
                            let route = path[index]
                            RecursiveNavLink(
                                path: $path,
                                index: index + 1,
                                content: buildDestination(route),
                                buildDestination: buildDestination
                            )
                        } else {
                            EmptyView()
                        }
                    },
                    label: {
                        EmptyView()
                    }
                )
                .hidden()
            )
    }
}
