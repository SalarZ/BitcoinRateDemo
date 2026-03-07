//
//  Date.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation

extension Date {
    var yearMonthDayFormatted: String {
        self.formatted(.dateTime.year().month().day())
    }
}
