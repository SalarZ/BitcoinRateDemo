//
//  BadgeView.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import SwiftUI

struct BadgeView: View {
    private enum Constants {
        static let horizontalPadding: CGFloat = 8
        static let verticalPadding: CGFloat = 4
    }

    let text: String
    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.bold)
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.vertical, Constants.verticalPadding)
            .background(.thinMaterial)
            .clipShape(Capsule())
    }
}

#Preview {
    BadgeView(text: "Live")
}
