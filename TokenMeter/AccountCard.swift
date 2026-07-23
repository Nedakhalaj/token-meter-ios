//
//  Untitled.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-07-22.
//

import SwiftUI

struct AccountCard: View {
    let account: Account
    let onRemove: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16){
            HStack(spacing: 12){
                Text(account.provider.initial)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(account.provider.accent, in: RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading, spacing: 2){
                    Text("\(account.provider.displayName) . \(account.nickname)")
                        .font(.headline)
                    Text(account.planName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Menu{
                    Button("Refresh"){}
                    Button("Rename"){}
                    Button("Remove", role: .destructive){ onRemove()}
                }label:{
                    Image(systemName: "ellipsis")
                        .foregroundStyle(.secondary)
                }
            }
            ForEach(account.windows) {window in
                UsageWindowRow(window: window)
                
            }
        }
        .padding( 16)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    AccountCard(account: Account.sample[0]){}
        .padding()
}
