//
//  TokenModels.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-07-21.
//

import Foundation

enum Provider: String {
    case claude
    case codex
    case openRouter
    case googleaDrive
    
    var displayName: String {
        switch self {
        case .claude:
            return "Claude"
        case .codex:
            return "Codex"
        case .openRouter:
            return "OpenRouter"
        case .googleaDrive:
            return "Google Drive"
        }
    }
}

struct UsageWindow:Identifiable {
    let id = UUID()
    let label: String
    let fraction: Double
    let resetsAt: Date
}

struct Account: Identifiable {
    let id = UUID()
    let provider: Provider
    let nickname: String
    let planName: String
    let windows: [UsageWindow]
}

extension Account {
    static var sample: [Account] = [
        Account(provider: .claude, nickname: "personal", planName: "Max 20x", windows: [UsageWindow(label: "5-hour", fraction: 0.42, resetsAt: Date().addingTimeInterval(60 * 60 * 2)),
                                                                                        UsageWindow(label: "7-day", fraction: 0.67, resetsAt: Date().addingTimeInterval(60 * 60 * 26))                                                                           ]),
        Account(provider: .codex, nickname: "work", planName: "ChatGPT pro", windows: [UsageWindow(label: "5-hour", fraction: 0.88, resetsAt: Date().addingTimeInterval(60 * 41))])
    ]
    
}


