//
//  AddAccountView.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-07-29.
//
import SwiftUI

struct AddAccountView: View {
    let onPick: (Provider) -> Void                 // mock providers 
    let onConnectOpenRouter: (String) -> Void      // the real one
    @Environment(\.dismiss) private var dismiss
    @State private var showingKey = false          // is the key sheet up?

    var body: some View {
        NavigationStack {
            List {
                ForEach(Provider.allCases, id: \.self) { provider in
                    Button {
                        if provider == .openRouter {
                            showingKey = true          // open the key screen
                        } else {
                            onPick(provider)           // mock: add immediately
                            dismiss()
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
        }
    }
}

                  

#Preview {
    AddAccountView (onPick: { _ in }, onConnectOpenRouter: { _ in })
}
