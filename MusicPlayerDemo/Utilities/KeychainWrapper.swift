//
//  KeychainHelper.swift
//  MusicPlayerDemo
//
//  Created by Eric Negron on 6/1/24.
//

import Foundation
import Security

class KeychainWrapper {
    
    static let shared = KeychainWrapper()
    private init() {}
    
    enum KeychainWrapperError: Error {
        case invalidData
        case serviceError
        case duplicateEntry
        case unknown(OSStatus)
    }
 
    func storeToken(_ token: String, forKey key: String) throws {
        guard let tokenData = token.data(using: .utf8) else {
            throw KeychainWrapperError.invalidData
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: tokenData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        switch status {
        case errSecDuplicateItem:
            throw KeychainWrapperError.duplicateEntry
        case errSecSuccess:
            break
        default:
            throw KeychainWrapperError.unknown(status)
        }
        
    }
    
    func getToken(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
       
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        
        return nil
    }
        
}
