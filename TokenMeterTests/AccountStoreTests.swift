//
//  AccountStoreTests.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-09-08.
//


import Foundation
import Testing

@testable import TokenMeter


@MainActor
struct AccountStoreTests{
    
    @Test func refreshMarksAccountFailedWhenKeyIsInvalid() async {
        
        //Arrange
        let account = Account(provider: .openRouter, nickname: "test",planName: "-", windows: [])
        let stub = StubUsageService(provider: .openRouter, errorToThrow: UsageError.invalidKey)
        let store = AccountStore(accounts: [account], services: [.openRouter: stub])
        
        //Act
        await store.refresh(account: account)
        
        //Assert
        #expect(store.states[account.id] == .failed("Invalid API key - reconnect"))
        
    }
    
    @Test func refreshStoresWindowsWhenFetchSucceeds() async{
        
        //Arrange
        let account = Account(provider: .openRouter, nickname: "test", planName: "-", windows: [])
        let windows = [UsageWindow(label: "5-hour", fraction: 0.5, resetsAt: nil)]
        let stub = StubUsageService(provider: .openRouter, windowsToReturn: windows)
        let store = AccountStore(accounts: [account], services: [.openRouter: stub])
        
        //Act
        await store.refresh(account: account)
        
        //Assert
        #expect(store.states[account.id ] == .loaded)
        #expect(store.accounts.first?.windows.count == 1)
        #expect(store.accounts.first?.windows.first?.fraction == 0.5)
    }
}
