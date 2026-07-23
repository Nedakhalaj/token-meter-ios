//
//  ContentView.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-07-21.
//

import SwiftUI

struct ContentView: View {
    @State private var store = AccountStore(accounts: Account.sample)
    
    var body: some View {
        DashboardView(store: store)
    }
}

#Preview {
    ContentView()
}
