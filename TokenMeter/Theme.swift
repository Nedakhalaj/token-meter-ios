//
//  theme.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-07-21.
//
import SwiftUI

enum Theme {
    static func color(for fraction : Double) -> Color {
        switch fraction {
        case ..<0.5: return .green
        case ..<0.8: return .orange
        default    : return .red
        }
    }
}

extension Provider{
    var accent: Color {
        switch self {
        case .claude: return Color(red: 0.85, green: 0.45, blue: 0.25)
        case .codex: return Color(red: 0.10, green: 0.65, blue: 0.55)
        case .openRouter: return Color(red: 0.35, green: 0.45, blue: 0.90)
        case .googleaDrive: return Color(red: 0.95, green: 0.75, blue: 0.20)
        }
    }
    
    var initial: String {
        String(displayName.prefix(1))
    }
}
