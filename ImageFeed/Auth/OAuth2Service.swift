//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Сергей Розов on 11.06.2025.
//

import Foundation

final class OAuth2Service {
    // MARK: - Constants
    private enum OAuth2ServiceConstants {
        static let unsplashSchemaAndHostNameString = "https://unsplash.com/"
        static let unsplashTokenPathString = "/oauth/token"
        static let unsplashGrantTypeString = "authorization_code"
    }
    
    static let shared = OAuth2Service()
    
    private init() {}
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: OAuth2ServiceConstants.unsplashSchemaAndHostNameString) else {
            assertionFailure("❌ Не удалось создать URLComponents из строки: \(OAuth2ServiceConstants.unsplashSchemaAndHostNameString)")
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
            assertionFailure("❌ Не удалось получить URL из urlComponents: \(urlComponents)")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NetworkError.urlSessionError))
            print("Неизвестная ошибка URLSession")
            return
        }
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let tokenResponse = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(tokenResponse.accessToken))
                } catch {
                    completion(.failure(error))
                    print("Ошибка декодирования OAuthTokenResponseBody:", error)
                }
            case .failure(let error):
                completion(.failure(error))
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case .httpStatusCode(let code):
                        print("Ошибка сервиса Unsplash, HTTP статус: \(code)")
                    case .urlRequestError(let error):
                        print("Сетевая ошибка: \(error)")
                    case .urlSessionError:
                        print("Неизвестная ошибка URLSession")
                    }
                } else {
                    print("Другая ошибка: \(error)")
                }
            }
        }
        task.resume()
    }
}
