//
//  AddAccountView.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-07-29.
//
import SwiftUI

struct AddAccountView: View {
    let onPick:(Provider) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Provider.allCases, id: \.self) { provider in
                    Button{
                        onPick(provider)
                        dismiss()
                    }label: {
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
            .navigationTitle("Add Account")
            .toolbar{
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        
    }
}

#Preview {
    AddAccountView { _ in } // do nothing when picked
}
