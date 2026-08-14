//
//  claudeModel.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-08-12.
//

import Foundation

struct ClaudeOrg: Decodable{
    let uuid: String?
}

struct ClaudeUsageResponse: Decodable{
    let limits: [ClaudeLimit]?    // NEW shape (a list)
    let five_hour: ClaudeWindow?
    let seven_day: ClaudeWindow?
}

struct ClaudeLimit: Decodable{
    let kind: String?
    let percent: Double?  //0-100
    let resets_at: String?
}

struct ClaudeWindow: Decodable{
    let utilization: Double?  //0-100
    let resets_at: String?
}
