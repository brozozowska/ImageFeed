//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Сергей Розов on 12.06.2025.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    private enum Keys: String {
        case token
    }
    
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    private let keychain = KeychainWrapper.standard
    
    var token: String? {
        get {
            keychain.string(forKey: Keys.token.rawValue)
        }
        set {
            if let newValue {
                keychain.set(newValue, forKey: Keys.token.rawValue)
            } else {
                keychain.removeObject(forKey: Keys.token.rawValue)
            }
        }
    }
}
