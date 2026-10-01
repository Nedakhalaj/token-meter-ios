//
//  theme.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-07-21.
//
import SwiftUI

// Colors from the Android app (ui/theme/Color.kt, UsageColors.kt, ProviderBranding.kt).
extension Color {
    /// A fixed color from a hex number, e.g. Color(hex: 0xD97757)
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255)
    }

    /// A color that switches automatically between light and dark mode.
    init(light: UInt32, dark: UInt32) {
        self.init(UIColor { traits in
            let hex = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: CGFloat((hex >> 16) & 0xFF) / 255,
                           green: CGFloat((hex >> 8) & 0xFF) / 255,
                           blue: CGFloat(hex & 0xFF) / 255,
                           alpha: 1)
        })
    }
}

enum Theme {
    // The dashboard's grouped list (Android GroupedColors.kt)
    static let groupedBackground = Color(light: 0xF2F2F7, dark: 0x1C1C1E)
    static let card              = Color(light: 0xFFFFFF, dark: 0x2C2C2E)
    static let separator         = Color(light: 0xE4E4EA, dark: 0x3A3A3C)

    // Text and bars
    static let secondaryText = Color(light: 0x46464F, dark: 0xC7C5D0)
    static let track         = Color(light: 0xE3E2EC, dark: 0x33343D)
    static let accent        = Color(light: 0x4F5AE0, dark: 0xBEC2FF)

    // Error banner
    static let errorBackground = Color(light: 0xFFDAD6, dark: 0x93000A)
    static let errorText       = Color(light: 0x410002, dark: 0xFFDAD6)



    // Quota states: under 50% ok, 50–80% warn, over 80% crit
    static let ok   = Color(light: 0x166B3A, dark: 0x4ADE80)
    static let warn = Color(light: 0x8F6400, dark: 0xFBBF24)
    static let crit = Color(light: 0xD32F3F, dark: 0xF87171)

    static func color(for fraction: Double) -> Color {
        switch fraction {
        case ..<0.5: return ok
        case ..<0.8: return warn
        default:     return crit
        }
    }
}

extension Provider {
    var accent: Color {
        switch self {
        case .claude:      return Color(hex: 0xD97757)
        case .codex:       return Color(hex: 0x3941FF)
        case .openRouter:  return Color(hex: 0x4C7EFF)
        case .googleDrive: return Color(hex: 0x1FA463)
        }
    }
    /// The logo's name in Assets.xcassets, e.g. "logo_openrouter"
    var logo: String {
        "logo_" + rawValue.lowercased()
    }

   
}
