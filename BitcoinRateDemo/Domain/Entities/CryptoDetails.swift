//
//  CryptoDetails.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation

struct CryptoDetails: Equatable {
    let name: String
    let eurPrice: Double?
    let usdPrice: Double?
    let gbpPrice: Double?
    let lastUpdate: Date
}
