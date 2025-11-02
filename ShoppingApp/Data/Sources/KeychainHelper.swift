//
//  KeychainHelper.swift
//  ShoppingApp
//
//  Created by Tin Pham on 2/11/25.
//

import Foundation
import Security


enum KeychainError: Error {
    case duplicateItem
    case unknown(OSStatus)
    case itemNotFound
}


final class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}
    
    
    func save(key: String, data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }
    
    func save(key: String, string: String) throws {
        guard let data = string.data(using: .utf8) else { return }
        try save(key: key, data: data)
    }
    
    func retrieve(key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data else {
            throw KeychainError.itemNotFound
        }
        
        return data
    }
    
    func retrieveString(key: String) throws -> String? {
        let data = try retrieve(key: key)
        return String(data: data, encoding: .utf8)
    }
    
    func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unknown(status)
        }
    }
}
