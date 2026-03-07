//
//  PriceRow.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation

struct PriceRow: Identifiable, Equatable {
    let id = UUID()
    let formattedDate: String
    let formattedPrice: String
}
