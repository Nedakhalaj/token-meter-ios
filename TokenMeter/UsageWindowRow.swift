//
//  UsageWindowRow.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-07-22.
//

import SwiftUI

struct UsageWindowRow: View {
    let window: UsageWindow
    
    
    var body: some View {
        
        VStack(alignment: .leading,spacing: 6){
            HStack{
                Text(window.label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(window.fraction, format: .percent.precision(.fractionLength(0)))
                    .font(.subheadline.weight(.semibold))
            }
            GeometryReader{geo in
                ZStack(alignment: .leading){
                    Capsule()
                        .fill(.quaternary)
                    Capsule()
                        .fill(Theme.color(for: window.fraction))
                        .frame(width: geo.size.width * min(max(window.fraction, 0), 1))
                }
                
            }
            .frame(height: 8)
            
            Text("resets \(window.resetsAt, style: .relative)")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        
    }
}

#Preview {
    UsageWindowRow(
        window: .init(label: "5-hour", fraction: 0.42, resetsAt: Date().addingTimeInterval(8000)))
    .padding()
}

