//
//  Double.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation

extension Double {
    func currencyFormatted(code: String) -> String {
        formatted(.currency(code: code.uppercased()))
    }
}
