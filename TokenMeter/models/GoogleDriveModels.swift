//
//  GoogleDriveModels.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-09-11.
//

import Foundation

struct DriveAboutResponse: Decodable {
    let storageQuota: StorageQuota?
    let user: DriveUser?
    
    struct StorageQuota: Decodable {
        let limit: String?
        let usage: String?
        let usageInDrive: String?
        let usageInDriveTrash: String?
        
        var limitBytes: Int64? {limit.flatMap(Int64.init)}
        var usageBytes: Int64? {usage.flatMap(Int64.init)}
        
    }
    
    struct DriveUser: Decodable {
        let displayName: String?
        let emailAddress: String?
    }
}

struct GoogleTokenResponse: Decodable {
    let access_token: String
    let refresh_token: String?
    let expires_in: Int?
    let token_type: String?
}

