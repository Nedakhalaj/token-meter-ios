//
//  AccountCard.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-07-22.
//

import SwiftUI

// One connected account, like Android's AccountCard: an inset-grouped card with a header row,
// then one row per usage window, separated by hairline dividers.
struct AccountCard: View {
    let account: Account
    let onRemove: () -> Void
    let onRefresh: () -> Void
    let onRename: (String) -> Void
    let onReconnect: () -> Void
    let state: LoadState?

    @State private var showingRename = false
    @State private var draftName = ""
    @State private var confirmingRemove = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

            if case .failed(let reason) = state {
                divider
                errorBanner(reason)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
            }

            if account.windows.isEmpty {
                if state == .loading {
                    divider
                    Text("Fetching usage…")
                        .font(.subheadline)
                        .foregroundStyle(Theme.secondaryText)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                }
            } else {
                ForEach(account.windows) { window in
                    divider
                    UsageWindowRow(window: window)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                }
            }
        }
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 18))
        .alert("Rename account", isPresented: $showingRename) {
            TextField("Name", text: $draftName)
            Button("Save") { onRename(draftName) }
            Button("Cancel", role: .cancel) { }
        }
        .confirmationDialog("Remove \(account.nickname)?", isPresented: $confirmingRemove, titleVisibility: .visible) {
            Button("Remove", role: .destructive) { onRemove() }
        } message: {
            Text("Its saved sign-in and usage are deleted from this device.")
        }
    }

    // Logo, name, provider, and the ··· menu.
    private var header: some View {
        HStack(spacing: 12) {
            Image(account.provider.logo)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(account.nickname)
                    .font(.title2.weight(.semibold))
                    .lineLimit(1)
                Text(account.provider.displayName)
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryText)
                    .lineLimit(1)
            }

            Spacer()

            if state == .loading && !account.windows.isEmpty {
                ProgressView()
            }

            Menu {
                Button("Refresh") { onRefresh() }
                Button("Reconnect") { onReconnect() }
                Button("Rename") {
                    draftName = account.nickname
                    showingRename = true
                }
                Button("Remove", role: .destructive) { confirmingRemove = true }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(Theme.secondaryText)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
        }
    }

    // A thin line between rows.
    private var divider: some View {
        Divider().overlay(Theme.separator)
    }

    private func errorBanner(_ reason: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(reason)
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button("Reconnect") { onReconnect() }
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(Theme.errorText)
        .padding(.leading, 16)
        .padding(.trailing, 8)
        .padding(.vertical, 8)
        .background(Theme.errorBackground, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview("Loaded") {
    AccountCard(account: Account.sample[0], onRemove: {}, onRefresh: {}, onRename: { _ in }, onReconnect: {}, state: .loaded)
        .padding()
        .background(Theme.groupedBackground)
}

#Preview("Failed") {
    AccountCard(account: Account.sample[1], onRemove: {}, onRefresh: {}, onRename: { _ in }, onReconnect: {}, state: .failed("Sign-in expired - reconnect"))
        .padding()
        .background(Theme.groupedBackground)
}
