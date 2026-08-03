//
//  Untitled.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-08-01.
//

import SwiftUI


struct ApiKeyView: View {
    
    let onConnect: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var Key = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("sk-or-...", text: $Key)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } header: {
                    Text("OpenRouter API key")
                } footer: {
                    Text("Paste a key from openrouter.ai/keys. It's stored only on this device, in the Keychain.")
                    
                }
            }
            .navigationTitle("Connect OpenRouter")
            .toolbar{
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Connect") {
                        onConnect(Key)
                        dismiss()
                    }
                    .disabled(Key.isEmpty)
                }
            }
        }
    }
}

#Preview {
    ApiKeyView(onConnect: {_ in })
}
