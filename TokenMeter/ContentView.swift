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
            .claude: ClaudeService(),
            .codex: MockUsageService(provider: .codex),
            .openRouter: OpenRouterService()
        ])
    )
    
    @AppStorage("theme") private var theme: ThemeMode = .system
  
    var body: some View {
        DashboardView(viewModel: viewModel)
            .preferredColorScheme(theme.colorScheme)
        
    }
    
  
}

#Preview {
    ContentView()
}
