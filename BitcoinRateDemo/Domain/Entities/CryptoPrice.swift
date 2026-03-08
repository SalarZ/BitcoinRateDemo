//
//  CryptoPrice.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation

struct CryptoPrice: Hashable {
    let date: Date
    let price: Double
    let coinId: String
}
