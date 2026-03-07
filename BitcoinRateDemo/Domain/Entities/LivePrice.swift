//
//  LivePrice.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation

struct LivePrice: Equatable {
    let name: String
    let prices: [String: Double]
    let lastUpdate: Date
}
