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
            print("❌ Не удалось создать URL запроса аватарки")
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
            completion(.failure(ProfileImageURLError.invalidToken))
            print("❌ Не удалось создать запрос URL аватарки")
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
                    completion(.failure(ProfileImageURLError.invalidRequest))
                    print("❌ Сервер вернул пустой ответ")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let userResult = try decoder.decode(UserResult.self, from: data)
                    let avatarURL = userResult.profileImage.small
                    self.avatarURL = avatarURL
                    completion(.success(avatarURL))
                    print("✅ Данные URL аватарки успешно декодированы")
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL]
                    )
                } catch {
                    completion(.failure(error))
                    print("❌ Ошибка декодирования данных URL аватарки:", error)
                }
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
}
