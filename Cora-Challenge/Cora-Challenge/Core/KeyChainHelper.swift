//
//  KeyChainHelper.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 26/06/24.
//

import Foundation
import Security

class KeychainHelper {
    static let shared = KeychainHelper()
    private let tokenKey = "authToken"
    
    private init() {}
    
    func saveToken(_ token: String) {
        let data = Data(token.utf8)
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: tokenKey,
            kSecValueData: data
        ] as CFDictionary
        
        SecItemDelete(query)
        SecItemAdd(query, nil)
    }
    
    func getToken() -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: tokenKey,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func deleteToken() {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: tokenKey
        ] as CFDictionary

        SecItemDelete(query)
    }
}
