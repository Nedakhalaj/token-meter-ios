//
//  AccountMigrationTests.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-10-01.
//

import Foundation
import Testing

@testable import TokenMeter

// Saved data from older app versions must keep loading after the model changes.
struct AccountMigrationTests {

    @Test func accountsSavedBeforeUpdatedAtExistedStillLoad() throws {
        // Arrange: JSON exactly as the previous version saved it, with no "updatedAt" key
        let oldJSON = """
        [{"id": "6F1A2B3C-0000-0000-0000-000000000001", "provider": "claude",
          "nickname": "personal", "planName": "Max", "windows": []}]
        """

        // Act
        let accounts = try JSONDecoder().decode([Account].self, from: Data(oldJSON.utf8))

        // Assert
        #expect(accounts.first?.nickname == "personal")
        #expect(accounts.first?.updatedAt == nil)
    }
}
