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
    case failed(LoadFailure)
}

/// Why a refresh failed. The card uses this to pick the right button.
enum LoadFailure: Equatable {
    case notSignedIn        // no saved sign-in for this account
    case signInExpired      // the provider rejected the saved sign-in
    case couldNotRefresh    // network trouble or a server problem

    var message: String {
        switch self {
        case .notSignedIn:     return "Not signed in"
        case .signInExpired:   return "Sign-in expired"
        case .couldNotRefresh: return "Couldn't refresh"
        }
    }

    /// Only a sign-in problem needs a new sign-in. Anything else just needs another try.
    var needsReconnect: Bool {
        self != .couldNotRefresh
    }
}
