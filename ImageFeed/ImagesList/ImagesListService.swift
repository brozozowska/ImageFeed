//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Сергей Розов on 10.07.2025.
//

import Foundation

enum ImagesListError: Error {
    case invalidURL
    case invalidToken
}

final class ImagesListService {
    
    // MARK: - Public Properties
    private(set) var photos: [Photo] = []
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    // MARK: - Private Properties
    private let urlSession = URLSession.shared
    private let storage = OAuth2TokenStorage()
    private var task: URLSessionDataTask?
    private var lastLoadedPage: Int?
    private var isLoading: Bool = false
        
    // MARK: - Constants
    private enum ImagesListServiceConstants {
        static let imagesListURLString = "https://api.unsplash.com/photos/"
    }
    
    // MARK: - Singleton
    static let shared = ImagesListService()
    private init() {}
    
    // MARK: - Public Methods
    func fetchPhotosNextPage() {
        guard !isLoading else { return }
        isLoading = true
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        var urlComponents = URLComponents(string: ImagesListServiceConstants.imagesListURLString)
        urlComponents?.queryItems = [
            URLQueryItem(name: "page", value: String(nextPage)),
            URLQueryItem(name: "per_page", value: "10"),
            URLQueryItem(name: "client_id", value: Constants.accessKey)
        ]
        guard let url = urlComponents?.url else {
            print("❌ [ImagesListService.fetchPhotosNextPage]: Failure - не удалось создать URL для запроса информации о фотографиях")
            isLoading = false
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map { Photo(from: $0)}
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    self.isLoading = false
                    print("✅ [ImagesListService.fetchPhotosNextPage]: Success - информация о фотографиях успешно загружена")
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self,
                        userInfo: ["photos": self.photos]
                    )
                }
            case .failure(let error):
                print("❌ [ImagesListService.fetchPhotosNextPage]: Failure - ошибка загрузки информации о фотографиях:", error)
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
        task?.resume()
    }
    
    func changeLike(
        photoID: String,
        isLike: Bool,
        _ completion: @escaping (Result<Void, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        
        let urlString = ImagesListServiceConstants.imagesListURLString + "\(photoID)/like"
        guard let url = URL(string: urlString) else {
            print("❌ [ImagesListService.changeLike]: Failure - Ошибка URL")
            completion(.failure(ImagesListError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        if let token = storage.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("❌ [ImagesListService.changeLike]: Failure - Нет токена")
            completion(.failure(ImagesListError.invalidToken))
            return
        }
        
        let task = urlSession.data(for: request) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success:
                if let index = self.photos.firstIndex(where: { $0.id == photoID }) {
                    let oldPhoto = self.photos[index]
                    let newPhoto = Photo(
                        id: oldPhoto.id,
                        size: oldPhoto.size,
                        createdAt: oldPhoto.createdAt,
                        welcomeDescription: oldPhoto.welcomeDescription,
                        thumbImageURL: oldPhoto.thumbImageURL,
                        largeImageURL: oldPhoto.largeImageURL,
                        isLiked: isLike
                    )
                    self.photos[index] = newPhoto
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }
                print("✅ [ImagesListService.changeLike]: Success - данные о лайке успешно декодированы и обновлены в локальном массиве")
                completion(.success(()))
                
            case .failure(let error):
                print("❌ [ImagesListService.changeLike]: Failure - ошибка при декодировании данных о лайке:", error)
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

// MARK: - UrlsResult
struct UrlsResult: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

// MARK: - PhotoResult
struct PhotoResult: Codable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let description: String?
    let likedByUser: Bool
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case description
        case likedByUser = "liked_by_user"
        case urls
    }
}

// MARK: - Photo
struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

// MARK: - Mapping
extension Photo {
    init(from result: PhotoResult) {
        self.id = result.id
        self.size = CGSize(width: result.width, height: result.height)
        
        if let createdAt = result.createdAt {
            let dateFormatter = ISO8601DateFormatter()
            self.createdAt = dateFormatter.date(from: createdAt)
        } else {
            self.createdAt = nil
        }
        
        self.welcomeDescription = result.description
        self.thumbImageURL = result.urls.thumb
        self.largeImageURL = result.urls.regular
        self.isLiked = result.likedByUser
    }
}
