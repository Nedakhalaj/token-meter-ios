//
//  AccountRepository.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-07-23.
//

import Foundation

@Observable
@MainActor
final class AccountStore  {
    
    //The store owns the accounts data and Data changes happen where the data lives.
    private(set) var accounts: [Account]
    
    private let services: [Provider: UsageService]
    
    private(set) var states: [UUID: LoadState] = [:]
    
    init(accounts: [Account], services: [Provider : UsageService] = [:]) {
        self.accounts = accounts
        self.services = services
    }
    
    init(services: [Provider : UsageService] = [:]){
        self.services = services
        self.accounts = AccountFileStore.load()
    }
    
    private func persist() {
        AccountFileStore.save(accounts)
    }
    
    
    func remove(_ account : Account) {
        accounts.removeAll(where: { $0.id == account.id })
        KeychainHelper.delete(for: account.id.uuidString)
        persist()
    }
     
    func add(_ account: Account)  {
        accounts.append(account)
        persist()
    }
     
    func refresh(account: Account) async  {
        states[account.id] = .loading
        do{
            guard let service = services[account.provider] else {
                states[account.id] = .failed("No service for this provider")
                return
                
            }
            let windows = try await service.fetchUsage(for: account)
            guard let i = accounts.firstIndex(where: {$0.id == account.id}) else { return }
            accounts[i] = account.replacingWindows(with: windows)
            states[account.id] = .loaded
            persist()
        }catch{
            states[account.id] = .failed(message(for: error))
        }
    }
    
    private func message(for error: Error) -> String {
        switch error{
            case UsageError.missingKey: return "No API key found - reconnect"
            case UsageError.invalidKey: return "Invalid API key - reconnect"
        default: return "Couldn't reftrsh"
        }
            
        }
    
    
    func refreshAll() async {
        await withTaskGroup(of: Void.self) { group in
            for account in accounts {
                group.addTask {
                  await self.refresh(account: account)
                }
            }
        }
    }
    
    func rename(_ account: Account, to newName: String) {
        guard let i = accounts.firstIndex(where: { $0.id == account.id }) else { return }
        accounts[i] = account.renamed(to: newName)
        persist()
    }
    
    
}

