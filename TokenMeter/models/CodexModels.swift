//
//  CodexModels.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-09-25.
//

import Foundation


// 1. POST auth.openai.com/api/accounts/deviceauth/usercode
struct CodexUserCodeResponse: Decodable{
    let device_auth_id: String
    let user_code: String?
    let usercode: String?     //openAI has sent both spellings
    let interval: String?        //seconds between polls
    
    var code: String { user_code ?? usercode ?? ""}
    var pollSeconds: Int { Int(interval ?? "") ?? 5 }
}


// 2. POST .../deviceauth/token (polling) returns this once you approve
struct CodexAuthCodeResponse: Decodable{
    let authorization_code: String
    let code_verifier: String
}


// 3. POST auth.openai.com/oauth/token (first exchange, and every refresh)
struct CodexTokenResponse: Decodable{
    let access_token: String?
    let refresh_token: String?
    let id_token: String?
    let expires_in: Int?
}


// 4. GET chatgpt.com/backend-api/wham/usage
struct CodexUsageResponse: Decodable{
    let plan_type: String?
    let email: String?
    let rate_limit: RateLimit?
    
    
    struct RateLimit: Decodable{
        let limit_reached: Bool?
        let primary_window: Window?        //usually 5_hour
        let secondary_window: Window?      //usually weekly
    }
    
    struct Window: Decodable{
        let used_percent: Double?          //0-100
        let limit_window_seconds: Int?     //18000 = 5h, 604800 = 7 days
        let reset_after_seconds: Int?      //seconds from now untill reset
        
    }
}
    
// Error replies while polling, e.g. {"error": "authorization_pending"}
struct CodexErrorResponse: Decodable {
    let error: String?
}


// What we keep in the Keychain for one Codex account, stored as JSON.
struct CodexCredential: Codable {
    let accessToken: String
    let refreshToken: String
    let lastRefresh: Date
}

extension CodexCredential {
    // Build one from OpenAI's token reply (after sign-in, or after a refresh).
    init(tokens: CodexTokenResponse) throws {
        guard let access = tokens.access_token, let refresh = tokens.refresh_token else {
            throw CodexAuthError.requestFailed
        }
        self.init(accessToken: access, refreshToken: refresh, lastRefresh: Date())
    }

    // Read one back from the Keychain string.
    init?(secret: String) {
        guard let value = try? JSONDecoder().decode(CodexCredential.self, from: Data(secret.utf8)) else {
            return nil
        }
        self = value
    }

    // Turn it into the string we save in the Keychain.
    var secret: String {
        let data = (try? JSONEncoder().encode(self)) ?? Data()
        return String(decoding: data, as: UTF8.self)
    }
}

    
    
    
