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
    
    func add(provider: Provider){
        let account = Account(provider: provider,nickname: "new", planName: "-", windows: [])
        repository.add(account)
    }
    
    func addOpenRouter(apiKey: String){
        let account = Account(provider: .openRouter, nickname: "OpenRouter", planName: "pay-as-you-go", windows: [])
        KeychainHelper.save(apiKey, for: account.id.uuidString)
        repository.add(account)
        Task{
            try? await repository.refresh(account: account)
        }
    }
    
    func refreshAccount(_ account: Account) {
        Task { try? await repository.refresh(account: account) }
    }
    
    func rename(_ account: Account, to newName: String) {
        repository.rename(account, to: newName)
    }


    
}

