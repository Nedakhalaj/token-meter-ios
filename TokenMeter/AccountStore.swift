//
//  AccountStore.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-07-22.
//

import Foundation


@Observable
final class AccountStore {
    var accounts: [Account]
    var isRefresging = false
    
    init(accounts: [Account] = []) {
        self.accounts = accounts
    }
    
    func remove(_ account: Account) {
        accounts.removeAll { $0.id == account.id }
    }
}
