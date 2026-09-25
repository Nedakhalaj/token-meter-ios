// xcode: set sdk=iOS

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
    
    
    init(repository: AccountStore) {
        self.repository = repository
    }
    
    var accounts : [Account] {
        repository.accounts
    }
    
     func refresh() async {
         await repository.refreshAll()
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
        repository.add(account, secret: apiKey)
        Task { await repository.refresh(account: account) }
    }
        
    
    func addClaude(sessionKey: String){
        let account = Account(provider: .claude, nickname: "Claude", planName: "pay-as-you-go", windows: [])
        repository.add(account, secret: sessionKey)
        Task { await repository.refresh(account: account) }
    }
    
        
    func addGoogleDrive(refreshToken: String) {
        let account = Account(provider: .googleDrive, nickname: "Google Drive", planName: "-", windows: [])
        repository.add(account, secret: refreshToken)
        Task { await repository.refresh(account: account) }
    }
    
    
    func refreshAccount(_ account: Account) {
        Task {  await repository.refresh(account: account) }
    }
    
    func rename(_ account: Account, to newName: String) {
        repository.rename(account, to: newName)
    }
    
    func state(for account: Account) -> LoadState? {
        repository.states[account.id]
    }
    
    
    func reconnect(account: Account, apiKey: String) {
        repository.updateSecret(apiKey, for: account)
        Task { await repository.refresh(account: account) }
    }

    
}

