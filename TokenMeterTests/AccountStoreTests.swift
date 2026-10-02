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
        #expect(store.states[account.id] == .failed(.signInExpired))

        
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
    @Test func successfulRefreshRecordsTheTime() async throws {
        // Arrange
        let account = Account(provider: .openRouter, nickname: "test", planName: "-", windows: [])
        let stub = StubUsageService(provider: .openRouter,
                                    windowsToReturn: [UsageWindow(label: "5-hour", fraction: 0.5, resetsAt: nil)])
        let store = AccountStore(accounts: [account], services: [.openRouter: stub])
        let before = Date()

        // Act
        await store.refresh(account: account)

        // Assert
        let updatedAt = try #require(store.accounts.first?.updatedAt)
        #expect(updatedAt >= before)
    }

    @Test func failedRefreshKeepsTheOldTime() async {
        // Arrange: an account that last updated successfully at a known time
        let lastSuccess = Date(timeIntervalSince1970: 1_000_000)
        let account = Account(provider: .openRouter, nickname: "test", planName: "-",
                              windows: [], updatedAt: lastSuccess)
        let stub = StubUsageService(provider: .openRouter, errorToThrow: UsageError.invalidKey)
        let store = AccountStore(accounts: [account], services: [.openRouter: stub])

        // Act
        await store.refresh(account: account)

        // Assert: the numbers didn't change, so neither does "updated …"
        #expect(store.accounts.first?.updatedAt == lastSuccess)
    }
    
    @Test func networkErrorAsksToRetryNotReconnect() async {
        // Arrange: the fetch fails the way it does with no internet
        let account = Account(provider: .openRouter, nickname: "test", planName: "-", windows: [])
        let stub = StubUsageService(provider: .openRouter, errorToThrow: URLError(.notConnectedToInternet))
        let store = AccountStore(accounts: [account], services: [.openRouter: stub])

        // Act
        await store.refresh(account: account)

        // Assert
        #expect(store.states[account.id] == .failed(.couldNotRefresh))
        #expect(LoadFailure.couldNotRefresh.needsReconnect == false)
        #expect(LoadFailure.signInExpired.needsReconnect == true)
    }

}
