//
//  BitcoinRateDemoApp.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import SwiftUI

@main
struct BitcoinRateDemoApp: App {
    private let container = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.container, container)
        }
    }
}
