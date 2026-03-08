//
//  PriceRow.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation

struct PriceRow: Identifiable, Equatable {
    let id = UUID()
    let date: String
    let price: String
    let onSelect: () -> Void

    static func == (lhs: PriceRow, rhs: PriceRow) -> Bool {
        return lhs.id == rhs.id
    }
}
