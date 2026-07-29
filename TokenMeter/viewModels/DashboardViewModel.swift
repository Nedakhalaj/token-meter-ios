//
//  DashboardViewModel.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-07-23.
//

import Foundation

@Observable
@MainActor
final class DashboardViewModel {
    
    let repository: AccountStore
    var osRefreshing = false
    
    init(repository: AccountStore) {
        self.repository = repository
    }
    
    var accounts : [Account] {
        repository.accounts
    }
    
     func refresh() async {
        osRefreshing = true
         await repository.refreshAll()
        osRefreshing = false
    }
    
    func remove(_ account: Account){
        repository.remove(account)
    }
}

