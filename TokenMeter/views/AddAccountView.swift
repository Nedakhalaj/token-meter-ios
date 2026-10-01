//
//  AddAccountView.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-07-29.
//
import SwiftUI

struct AddAccountView: View {
    let onConnectOpenRouter: (String) -> Void
    let onConnectClaude: (String) -> Void
    let onConnectGoogleDrive: (String) -> Void
    let onConnectCodex: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var showingKey = false          // is the key sheet up?
    @State private var showingClaudeLogin = false
    @State private var googleAuth = GoogleAuthService()
    @State private var showingCodexLogin = false
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Pick a provider")
                        .font(.title2.weight(.semibold))
                    Text("Add as many accounts as you like, one per sign-in. Each one is read separately on the dashboard and widget.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.secondaryText)

                    VStack(spacing: 0) {
                        ForEach(Provider.allCases, id: \.self) { provider in
                            if provider != Provider.allCases.first {
                                Divider().overlay(Theme.separator)
                            }
                            Button { pick(provider) } label: { row(provider) }
                                .buttonStyle(.plain)
                        }
                    }
                    .background(Theme.card, in: RoundedRectangle(cornerRadius: 18))

                    Text("Credentials are stored only on this device. Token Meter reads each provider's own usage endpoints.")
                        .font(.caption2)
                        .foregroundStyle(Theme.secondaryText)
                        .padding(.horizontal, 12)
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .frame(maxWidth: 640)
                .frame(maxWidth: .infinity)
            }
            .background(Theme.groupedBackground)

            .navigationTitle("Add account")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            
            .sheet(isPresented: $showingKey) {
                ApiKeyView{ key in
                    onConnectOpenRouter(key)   // hand the key up to the dashboard
                    dismiss()                  // close the picker too
                }
            }
            .sheet(isPresented: $showingClaudeLogin) {
                ClaudeLoginScreen{ sessionKey in
                    onConnectClaude(sessionKey)
                    dismiss()
                }
            }
            .sheet(isPresented: $showingCodexLogin) {
                CodexLoginScreen { secret in
                    onConnectCodex(secret)
                    dismiss()
                }
            }
            
        }
    }
    
    // What happens when a provider is tapped.
    private func pick(_ provider: Provider) {
        switch provider {
        case .openRouter:
            showingKey = true
        case .claude:
            showingClaudeLogin = true
        case .googleDrive:
            Task {
                do {
                    onConnectGoogleDrive(try await googleAuth.signIn())
                    dismiss()
                } catch {
                    print("❌ Google Drive connect failed:", error)
                }
            }
        case .codex:
            showingCodexLogin = true
        }
    }

    // One row: badge, name, description, chevron.
    private func row(_ provider: Provider) -> some View {
        HStack(spacing: 12) {
            ProviderBadge(provider: provider)
            VStack(alignment: .leading, spacing: 2) {
                Text(provider.displayName)
                    .font(.body)
                    .foregroundStyle(.primary)
                Text(provider.accountKind)
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryText)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(Theme.secondaryText)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }

}



#Preview {
    AddAccountView (onConnectOpenRouter: { _ in }, onConnectClaude: { _ in }, onConnectGoogleDrive: { _ in }, onConnectCodex: { _ in })
}
