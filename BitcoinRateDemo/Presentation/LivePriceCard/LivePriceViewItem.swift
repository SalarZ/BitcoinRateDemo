//
//  LivePriceViewItem.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation

struct LivePriceViewItem: Equatable {
    let id = UUID()
    let price: String
    let lastUpdated: String
}
