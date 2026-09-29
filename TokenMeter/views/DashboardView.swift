//
//  DashboardView.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-07-22.
//

import SwiftUI

struct DashboardView: View {
    let viewModel: DashboardViewModel
    @State private var showingAdd = false
    @State private var reconnectingAccount: Account?
    @State private var isSetting = false
    @State private var googleAuth = GoogleAuthService()

    var body:some View {
        NavigationStack{
            Group{
                if viewModel.accounts.isEmpty {
                    emptyState
                }else{
                    ScrollView(){
                        LazyVStack(spacing: 16){
                            ForEach(viewModel.accounts) { account in
                                AccountCard(account: account,
                                            onRemove: { viewModel.remove(account) },
                                            onRefresh: { viewModel.refreshAccount(account) }, onRename: {newName in viewModel.rename(account, to: newName)}, onReconnect: { reconnect(account) }, state: viewModel.state(for: account)
                                )
                            }
                        }
                        .padding(16)
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .navigationTitle("Token Meter")
            .toolbar(){
                ToolbarItem{
                    HStack {
                        Button{
                            showingAdd = true
                        }label: {
                            Image(systemName: "plus")
                        }
                        
                        
                        Button{
                            isSetting = true
                        }label: {
                            Image(systemName: "gearshape")
                        }
                    }
                    
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddAccountView(
                onConnectOpenRouter: { key in
                    viewModel.addOpenRouter(apiKey: key)
                }, onConnectClaude: {key in viewModel.addClaude(sessionKey: key)}, onConnectGoogleDrive: {token in viewModel.addGoogleDrive(refreshToken: token)},
                onConnectCodex: { secret in viewModel.addCodex(secret: secret) }
            )
        }
        .sheet(isPresented: $isSetting){
           SettingView()
        }
        
        .sheet(item: $reconnectingAccount) { account in
            switch account.provider {
            case .openRouter:
                ApiKeyView { key in
                    viewModel.reconnect(account: account, secret: key)
                }
            case .claude:
                ClaudeLoginScreen { key in
                    viewModel.reconnect(account: account, secret: key)
                    reconnectingAccount = nil
                }
            case .codex:
                CodexLoginScreen { secret in
                    viewModel.reconnect(account: account, secret: secret)
                    reconnectingAccount = nil
                }
            case .googleDrive:
                EmptyView()    // Google has no sheet: see reconnect(_:) below
            }
        }
    }

    // Google opens its own login window, so it skips the sheet.
    private func reconnect(_ account: Account) {
        if account.provider == .googleDrive {
            Task {
                if let token = try? await googleAuth.signIn() {
                    viewModel.reconnect(account: account, secret: token)
                }
            }
        } else {
            reconnectingAccount = account
        }
    }

    
    private var emptyState: some View {
        ContentUnavailableView{
            Label("No accounts yet", systemImage: "gauge.with.dots.needle.33percent")
        } description: {
            Text("Connect a provider to start watching your quota.")
        }actions: {
            Button("Add your first account"){
                showingAdd = true
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview("With accounts") {
    DashboardView(viewModel: DashboardViewModel(repository: AccountStore(accounts: Account.sample)))
}

#Preview("Empty") {
    DashboardView(viewModel: DashboardViewModel(repository: AccountStore(accounts: Account.sample)))
    
}
