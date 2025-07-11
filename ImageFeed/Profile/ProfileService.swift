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
            print("❌ [ProfileService.makeProfileRequest]: Failure - не удалось создать URL для профиля")
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
            print("❌ [ProfileService.fetchProfile]: Failure - не удалось создать запрос профиля")
            completion(.failure(ProfileError.invalidToken))
            return
        }
        
        let currentTask = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else { return }
            
            defer {
                self.task = nil
            }
            
            switch result {
            case .success(let profileResponse):
                let profile = Profile(from: profileResponse)
                self.profile = profile
                print("✅ [ProfileService.fetchProfile]: Success - данные профиля успешно декодированы")
                completion(.success(profile))
            case .failure(let error):
                print("❌ [ProfileService.fetchProfile]: Failure - Ошибка запроса или декодирования ProfileResult:", error)
                completion(.failure(error))
            }
        }
        self.task = currentTask
        currentTask.resume()
    }
}

// MARK: - ProfileResult
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

// MARK: - Profile
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
