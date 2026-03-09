//
//  RootView.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/8/26.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var container: DependencyContainer

    var body: some View {
        CoordinatedView(HomeCoordinator(navigationController: NavigationController(), container: container))
    }
}

#Preview {
    let container = DependencyContainer()
    return RootView()
        .environmentObject(container)
}
