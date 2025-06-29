//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Сергей Розов on 11.06.2025.
//

import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    // MARK: - Private Properties
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    // MARK: - Constants
    private enum OAuth2ServiceConstants {
        static let unsplashSchemaAndHostNameString = "https://unsplash.com/"
        static let unsplashTokenPathString = "/oauth/token"
        static let unsplashGrantTypeString = "authorization_code"
    }
    
    // MARK: - Singleton
    static let shared = OAuth2Service()
    private init() {}
    
    // MARK: - Private Methods
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: OAuth2ServiceConstants.unsplashSchemaAndHostNameString) else {
            print("❌ [OAuth2Service.makeOAuthTokenRequest]: Failure - не удалось создать URLComponents из строки: \(OAuth2ServiceConstants.unsplashSchemaAndHostNameString)")
            return nil
        }
        urlComponents.path = OAuth2ServiceConstants.unsplashTokenPathString
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: OAuth2ServiceConstants.unsplashGrantTypeString)
        ]
        guard let url = urlComponents.url else {
            print("❌ [OAuth2Service.makeOAuthTokenRequest]: Failure - не удалось получить URL из URLComponents: \(urlComponents)")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    // MARK: - Public Methods
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            print("❌ [OAuth2Service.fetchOAuthToken]: Failure - повторный код авторизации")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("❌ [OAuth2Service.fetchOAuthToken]: Failure - не удалось собрать URLRequest")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let currentTask = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else { return }
            
            defer {
                self.task = nil
                self.lastCode = nil
            }
            
            switch result {
            case .success(let tokenResponse):
                let storage = OAuth2TokenStorage()
                storage.token = tokenResponse.accessToken
                print("✅ [OAuth2Service.fetchOAuthToken]: Success - токен сохранён в UserDefaults: \(storage.token ?? "nil")")
                completion(.success(tokenResponse.accessToken))
            case .failure(let error):
                print("❌ [OAuth2Service.fetchOAuthToken]: Failure - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        self.task = currentTask
        currentTask.resume()
    }
}
