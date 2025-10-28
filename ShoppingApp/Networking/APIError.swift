//
//  APIError.swift
//  ShoppingApp
//
//  Created by Tín Phạm on 12/10/25.
//

import Foundation

public enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(underlying: Error)
    case badStatus(code: Int, data: Data?)
    case decodingFailed(underlying: Error)
    case unknown

    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "The URL is invalid."
        case .requestFailed(let underlying): return "Network request failed: \(underlying.localizedDescription)"
        case .badStatus(let code, _): return "Server returned status code \(code)."
        case .decodingFailed(let underlying): return "Failed to decode response: \(underlying.localizedDescription)"
        case .unknown: return "An unknown error occurred."
        }
    }
}
