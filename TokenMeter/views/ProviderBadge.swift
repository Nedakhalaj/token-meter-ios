//
//  ProviderBadge.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-10-01.
//

import SwiftUI

// A provider's logo on a soft tinted rounded square, like Android's ProviderBadge.
struct ProviderBadge: View {
    let provider: Provider
    var size: CGFloat = 44

    var body: some View {
        Image(provider.logo)
            .resizable()
            .scaledToFit()
            .frame(width: size * 0.55, height: size * 0.55)
            .frame(width: size, height: size)
            .background(provider.accent.opacity(0.14),
                        in: RoundedRectangle(cornerRadius: size * 0.32))
    }
}

#Preview {
    HStack {
        ForEach(Provider.allCases, id: \.self) { ProviderBadge(provider: $0) }
    }
    .padding()
}
