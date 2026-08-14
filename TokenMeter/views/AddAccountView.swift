//
//  AddAccountView.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-07-29.
//
import SwiftUI

struct AddAccountView: View {
    let onPick: (Provider) -> Void                 // mock providers 
    let onConnectOpenRouter: (String) -> Void
    let onConnectClaude: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showingKey = false          // is the key sheet up?
    @State private var showingClaudeLogin = false
    
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Provider.allCases, id: \.self) { provider in
                    Button {
                       switch provider {
                            case .openRouter:
                           showingKey = true
                           case .claude:
                           showingClaudeLogin = true
                       default: onPick(provider); dismiss()
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Text(provider.initial)
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(width: 36, height: 36)
                                .background(provider.accent, in: RoundedRectangle(cornerRadius: 10))
                            Text(provider.displayName)
                                .font(.body)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
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
        }
    }
}

                  

#Preview {
    AddAccountView (onPick: { _ in }, onConnectOpenRouter: { _ in }, onConnectClaude: { _ in })
}
