//
//  AccountFileStore.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-08-04.
//

import Foundation

enum AccountFileStore {
    
    private static var fileURL: URL {
        URL.documentsDirectory.appending(path: "accounts.json")
    }
    
    static func save (_ accounts: [Account]) {
        do{
            let data = try JSONEncoder().encode(accounts)
            try data.write(to: fileURL)
        }catch{
            print("Couldnt save accounts:", error)
        }
    }
    
    static func load() -> [Account]{
        do{
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([Account].self, from: data)
        }catch {
            return []
        }
    }
    
}
