//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by Сергей Розов on 30.07.2025.
//

import Foundation

// MARK: - Protocol
protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}

// MARK: - AuthHelper
final class AuthHelper: AuthHelperProtocol {
    
    // MARK: - Public Properties
    let configuration: AuthConfiguration
    
    // MARK: - Initializers
    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }
    
    // MARK: - Public Methods
    func authRequest() -> URLRequest? {
        guard let url = authURL() else { return nil }
        return URLRequest(url: url)
    }
    
    func authURL() -> URL? {
        guard var urlComponents = URLComponents(string: configuration.authURLString) else {
            print("❌ [AuthHelper.authURL]: Failure - не удалось создать URLComponents из строки: \(configuration.authURLString)")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope)
        ]
        
        return urlComponents.url
    }
    
    func code(from url: URL) -> String? {
        if
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            print("🔄 [AuthHelper.code]: Переход на URL: \(url.absoluteString)")
            print("✅ [AuthHelper.code]: Success - код авторизации получен: \(codeItem)")
            return codeItem.value
        } else {
            print("🔄 [AuthHelper.code]: Переход на URL: \(url.absoluteString)")
            return nil
        }
    }
}
