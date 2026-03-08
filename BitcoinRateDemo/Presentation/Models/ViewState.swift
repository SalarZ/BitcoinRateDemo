//
//  ViewState.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

enum ViewState<T: Equatable>: Equatable {
    case loading
    case loaded(T)
    case failure(String)
}
