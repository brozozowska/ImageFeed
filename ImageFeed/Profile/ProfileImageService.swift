//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Сергей Розов on 27.06.2025.
//

import Foundation

enum ProfileImageURLError: Error {
    case invalidToken
    case invalidRequest
}

final class ProfileImageService {
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
   
    // MARK: - Private Properties
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var avatarURL: String?
    
    // MARK: - Constants
    private enum ProfileImageServiceConstants {
        static let profileImageURLString = "https://api.unsplash.com/users/"
    }
    
    // MARK: - Singleton
    static let shared = ProfileImageService()
    private init() {}
    
    // MARK: - Private Methods
    private func makeProfileImageURLRequest(username: String, token: String) -> URLRequest? {
        let urlString = "\(ProfileImageServiceConstants.profileImageURLString)\(username)"
        guard let url = URL(string: urlString) else {
            print("❌ [ProfileImageService.makeProfileImageURLRequest]: Failure - не удалось создать URL для запроса аватарки")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    // MARK: - Public Methods
    func fetchProfileImageURL(username: String, token: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let request = makeProfileImageURLRequest(username: username, token: token) else {
            print("❌ [ProfileImageService.fetchProfileImageURL]: Failure - не удалось создать запрос URL аватарки")
            completion(.failure(ProfileImageURLError.invalidToken))
            return
        }
                                                       
        let currentTask = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }

            defer {
                self.task = nil
            }
            
            switch result {
            case .success(let userResult):
                let avatarURL = userResult.profileImage.large
                self.avatarURL = avatarURL
                print("✅ [ProfileImageService.fetchProfileImageURL]: Success - данные URL аватарки успешно декодированы")
                completion(.success(avatarURL))
                
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": avatarURL]
                )
            case .failure(let error):
                print("❌ [ProfileImageService.fetchProfileImageURL]: Failure - ошибка при запросе или декодирования URL аватарки:", error)
                completion(.failure(error))
            }
        }
        self.task = currentTask
        currentTask.resume()
    }
}

struct UserResult: Codable {
    let profileImage: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
}
