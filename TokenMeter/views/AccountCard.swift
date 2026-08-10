//
//  AccountCard.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-07-22.
//

import SwiftUI

struct AccountCard: View {
    let account: Account
    let onRemove: () -> Void
    let onRefresh: () -> Void
    let onRename: (String) -> Void
    let onReconnect: () -> Void
    let state: LoadState?

    @State private var showingRename = false  // is the alert up?
    @State private var draftName = ""         // the text being typed

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Text(account.provider.initial)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(account.provider.accent, in: RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(account.provider.displayName) . \(account.nickname)")
                        .font(.headline)
                    Text(account.planName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Menu {
                    Button("Refresh") { onRefresh() }
                    Button("Rename") {
                        draftName = account.nickname
                        showingRename = true
                    }
                    Button("Reconnect"){
                        onReconnect()
                    }
                    Button("Remove", role: .destructive) { onRemove() }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(.secondary)
                }
            }

            ForEach(account.windows) { window in
                UsageWindowRow(window: window)
            }
            
            switch state{
            case .loading:
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Loading...").font(.caption).foregroundStyle(.secondary)
                }
            case .failed(let reason):
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.red)
                    Text(reason)
                        .font(.caption).foregroundStyle(.red)
                    Spacer()
                    Button("Reconnect") { onReconnect() }.font(.caption)
                }
            case .loaded, .none:
                EmptyView()
            }
        }
        .padding(16)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 16))
        .alert("Rename account", isPresented: $showingRename) {
            TextField("Name", text: $draftName)
            Button("Save") { onRename(draftName) }
            Button("Cancel", role: .cancel) { }
        }
    }
}

#Preview {
    AccountCard(account: Account.sample[0], onRemove: {}, onRefresh: {}, onRename: { _ in }, onReconnect: {}, state: .loaded)
        .padding()
}
