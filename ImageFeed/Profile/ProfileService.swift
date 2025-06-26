//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Сергей Розов on 25.06.2025.
//

import Foundation

enum ProfileError: Error {
    case invalidToken
    case invalidRequest
}

final class ProfileService {
    
    // MARK: - Private Properties
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastToken: String?
    private(set) var profile: Profile?
    
    // MARK: - Constants
    private enum ProfileServiceConstants {
        static let profileURLString = "https://api.unsplash.com/me"
    }
    
    // MARK: - Singleton
    static let shared = ProfileService()
    private init() {}
    
    // MARK: - Private Methods
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: ProfileServiceConstants.profileURLString) else {
            print("❌ Не удалось создать URL для профиля")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    // MARK: - Public Methods
    func fetchProfile(token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(ProfileError.invalidToken))
            print("❌ Не удалось создать запрос профиля")
            return
        }
        
        let currentTask = urlSession.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self else { return }
                
                defer {
                    self.task = nil
                }
                
                if let error {
                    completion(.failure(error))
                    print("❌ Ошибка запроса: \(error)")
                    return
                }
                
                guard let data else {
                    completion(.failure(ProfileError.invalidRequest))
                    print("❌ Сервер вернул пустой ответ")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let profileResponse = try decoder.decode(ProfileResult.self, from: data)
                    let profile = Profile(from: profileResponse)
                    self.profile = profile
                    completion(.success(profile))
                    print("✅ Данные профиля успешно декодированы")
                } catch {
                    completion(.failure(error))
                    print("❌ Ошибка декодирования ProfileResult:", error)
                }
            }
        }
        self.task = currentTask
        currentTask.resume()
    }
}

struct ProfileResult: Codable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    
    init(from result: ProfileResult) {
        self.username = result.username
        self.name = [result.firstName, result.lastName]
            .compactMap { $0 }
            .joined(separator: " ")
        self.loginName = "@\(result.username)"
        self.bio = result.bio
    }
}
