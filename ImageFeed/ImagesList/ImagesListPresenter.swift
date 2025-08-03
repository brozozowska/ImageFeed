//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Сергей Розов on 02.08.2025.
//

import Foundation

// MARK: - Protocol
protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photosCount: Int { get }
    func viewDidLoad()
    func photo(at index: Int) -> Photo
    func formattedDate(at index: Int) -> String
    func heightForImage(at index: Int, tableViewWidth: CGFloat) -> CGFloat
    func didSelectImage(at index: Int)
    func willDisplayCell(at index: Int)
    func toggleLike(at index: Int)
}

// MARK: - Presenter
final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    // MARK: - Public Properties
    weak var view: ImagesListViewControllerProtocol?
    
    // MARK: - Private Properties
    private var photos: [Photo] = []
    private let service: ImagesListServiceProtocol
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Initializers
    init(service: ImagesListServiceProtocol = ImagesListService.shared) {
        self.service = service
    }
    
    var photosCount: Int {
        photos.count
    }
    
    // MARK: - Lifecycle
    func viewDidLoad() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            let oldCount = self.photos.count
            let newPhotos = self.service.photos
            self.photos = newPhotos
            
            let newCount = newPhotos.count
            guard oldCount != newCount else { return }
            
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            self.view?.insertRows(at: indexPaths)
        }
        service.fetchPhotosNextPage()
    }
    
    // MARK: - Public Methods
    func photo(at index: Int) -> Photo {
        photos[index]
    }
    
    func formattedDate(at index: Int) -> String {
        guard let date = photos[index].createdAt else { return "" }
        return Self.dateFormatter.string(from: date)
    }
    
    func heightForImage(at index: Int, tableViewWidth: CGFloat) -> CGFloat {
        let photo = photos[index]
        let imageSize = photo.size
        let scale = tableViewWidth / imageSize.width
        return imageSize.height * scale
    }
    
    func willDisplayCell(at index: Int) {
        if index == photosCount - 1 {
            service.fetchPhotosNextPage()
        }
    }
    
    func didSelectImage(at index: Int) {
        let photo = photos[index]
        guard let url = URL(string: photo.largeImageURL) else { return }
        view?.performSegueToSingleImage(at: IndexPath(row: index, section: 0), url: url)
    }
    
    func toggleLike(at index: Int) {
        let photo = photos[index]
        let photoID = photo.id
        let isLike = !photo.isLiked
        
        UIBlockingProgressHUD.show()
        
        service.changeLike(photoID: photoID, isLike: isLike) { [weak self] result in
            guard let self else { return }
            
            defer { UIBlockingProgressHUD.dismiss() }
            
            switch result {
            case .success:
                self.photos = self.service.photos
                self.view?.reloadRows(at: [IndexPath(row: index, section: 0)])
            case .failure(let error):
                print("❌ [ImagesListPresenter.toggleLike]: Ошибка изменения лайка:", error)
                // TODO: Показать ошибку с использованием UIAlertController
            }
        }
    }
}
