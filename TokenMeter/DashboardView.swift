//
//  DashboardView.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-07-22.
//

import SwiftUI

struct DashboardView: View {
    let store : AccountStore
    
    
    var body:some View {
        NavigationStack{
            Group{
                if store.accounts.isEmpty {
                    emptyState
                }else{
                    ScrollView(){
                        LazyVStack(spacing: 16){
                            ForEach(store.accounts) { account in
                                AccountCard(account: account){
                                    store.remove(account)
                                }
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Token Meter")
            .toolbar{
                ToolbarItem(placement: .primaryAction){
                    Button{
                        //TODO: add account
                    }label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
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
    DashboardView(store: AccountStore(accounts: Account.sample))

}
#Preview("Empty"){
    DashboardView(store: AccountStore())

}
