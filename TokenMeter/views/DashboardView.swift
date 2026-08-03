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
    
    var body:some View {
        NavigationStack{
            Group{
                if viewModel.accounts.isEmpty {
                    emptyState
                }else{
                    ScrollView(){
                        LazyVStack(spacing: 16){
                            ForEach(viewModel.accounts) { account in
                                AccountCard(account: account){
                                    viewModel.remove(account)
                                }
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
            .toolbar{
                ToolbarItem(placement: .primaryAction){
                    Button{
                        showingAdd = true
                    }label: {
                        Image(systemName: "plus")
                    }
                
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddAccountView(
                onPick: { provider in
                    viewModel.add(provider: provider)
                },
                onConnectOpenRouter: { key in
                    viewModel.addOpenRouter(apiKey: key)
                }
            )
        }    }
    private var emptyState: some View {
        ContentUnavailableView{
            Label("No accounts yet", systemImage: "gauge.with.dots.needle.33percent")
        } description: {
            Text("Connect a provider to start watching your quota.")
        }actions: {
            Button("Add your first account"){
                //TODO: add account
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
