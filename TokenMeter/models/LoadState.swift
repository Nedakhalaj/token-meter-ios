//
//  LoadState.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-08-07.
//

import Foundation

enum LoadState: Equatable {
    case loading
    case loaded
    case failed(String)
}
