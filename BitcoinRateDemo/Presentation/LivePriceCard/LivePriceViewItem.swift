//
//  LivePriceViewItem.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation

struct LivePriceViewItem: Identifiable, Equatable {
    let id = UUID()
    // TODO: Salar check if we need to rename it to use formatted price or only price
    let priceText: String
    let lastUpdated: String
}
