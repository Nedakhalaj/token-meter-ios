//
//  UsageWindowRow.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-07-22.
//


import SwiftUI

// One usage window, like Android's WindowRow: label, bar, then "% used" and the reset time.
struct UsageWindowRow: View {
    let window: UsageWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(window.label)
                .font(.callout.weight(.semibold))

            UsageBar(fraction: window.fraction)
                .padding(.top, 12)

            HStack {
                Text("\(Int((window.fraction * 100).rounded()))% used")
                    .foregroundStyle(Theme.color(for: window.fraction))
                Spacer()
                if let resetsAt = window.resetsAt {
                    Text("Resets in \(resetsAt, style: .relative)")
                        .foregroundStyle(Theme.secondaryText)
                } else {
                    Text("No reset time")
                        .foregroundStyle(Theme.secondaryText)
                }
            }
            .font(.subheadline.weight(.medium).monospacedDigit())
            .padding(.top, 8)
        }
    }
}

// The bar itself: a rounded track with a colored fill, 8pt high.
struct UsageBar: View {
    let fraction: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.track)
                Capsule()
                    .fill(Theme.color(for: fraction))
                    .frame(width: geo.size.width * min(max(fraction, 0), 1))
            }
        }
        .frame(height: 8)
        .animation(.default, value: fraction)
        .accessibilityHidden(true)    // the "42% used" text already says it
    }
}

#Preview {
    VStack(spacing: 24) {
        UsageWindowRow(window: .init(label: "5-hour", fraction: 0.42, resetsAt: Date().addingTimeInterval(8000)))
        UsageWindowRow(window: .init(label: "Weekly", fraction: 0.67, resetsAt: nil))
        UsageWindowRow(window: .init(label: "Storage", fraction: 0.91, resetsAt: nil))
    }
    .padding(20)
}
