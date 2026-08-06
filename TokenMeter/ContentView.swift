//
//  ContentView.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-07-21.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = DashboardViewModel(
        repository: AccountStore(services: [
            .claude: MockUsageService(provider: .claude),
            .codex: MockUsageService(provider: .codex),
            .openRouter: OpenRouterService()
        ])
    )

   
    
    var body: some View {
        DashboardView(viewModel: viewModel)
        
    }
}

#Preview {
    ContentView()
}
