//
//  OpenRouterModels.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-07-30.
//


import Foundation

struct OpenRouterCreditsResponse: Decodable{
    
    let data: Credits
    
    struct Credits : Decodable{
        
        let total_credits: Double
        let total_usage: Double
    }
}
