//
//  ClaudeLoginScreen.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-08-10.
//
import SwiftUI

struct ClaudeLoginScreen: View {
    let onCapture: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack{
            ClaudeLoginView(onCapture: onCapture)
                .navigationTitle("Sign in to Claude")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar{
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
        }
    }
}
