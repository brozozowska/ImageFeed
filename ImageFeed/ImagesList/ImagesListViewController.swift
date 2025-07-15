//
//  ViewController.swift
//  ImageFeed
//
//  Created by Сергей Розов on 15.05.2025.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    // MARK: - UI Elements
    private let tableView = UITableView()
    
    // MARK: - Private Properties
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var photos: [Photo] = []
    private let imagesListService = ImagesListService.shared
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        tabBarController?.tabBar.isTranslucent = false
        tabBarController?.tabBar.backgroundColor = .ypBlack
 
        setupTableView()
        setupLayout()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableViewAnimated),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        
        imagesListService.fetchPhotosNextPage()
    }
    
    // MARK: - Setup Methods
    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("❌ [ImagesListViewController.prepare]: Недопустимая цель перехода")
                return
            }
            let photo = photos[indexPath.row]
            viewController.fullImageURL = URL(string: photo.largeImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Private Methods
    @objc private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        guard oldCount != newCount else { return }
        
        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageSize = photo.size
        let imageViewWidth = tableView.bounds.width
        let scale = imageViewWidth / imageSize.width
        let imageViewHeight = imageSize.height * scale
        return imageViewHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        let photo = photos[indexPath.row]
        
        imageListCell.delegate = self
        
        imageListCell.placeholderImageView.image = UIImage(named: "stub")
        imageListCell.placeholderImageView.isHidden = false
                        
        if let url = URL(string: photo.thumbImageURL) {
            imageListCell.cellImage.kf.setImage(with: url) { result in
                switch result {
                case .success:
                    imageListCell.placeholderImageView.isHidden = true
                    tableView.performBatchUpdates(nil)
                case .failure(let error):
                    imageListCell.placeholderImageView.isHidden = false
                    print("⚠️ [ImagesListViewController.tableView]: Ошибка загрузки картинки:", error)
                }
            }
        } else {
            imageListCell.placeholderImageView.isHidden = false
        }
        
        imageListCell.dateLabel.text = photo.createdAt.map { dateFormatter.string(from: $0) } ?? ""
        
        let likeImageName = photo.isLiked ? "Favorites Active" : "Favorites No Active"
        imageListCell.likeButton.setImage(UIImage(named: likeImageName), for: .normal)
        
        return imageListCell
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("❌ [ImagesListViewController.imageListCellDidTapLike]: Не удалось найти indexPath для ячейки")
            return
        }
        
        let photo = photos[indexPath.row]
        let photoID = photo.id
        let isLike = !photo.isLiked
        
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoID: photoID, isLike: isLike) { [weak self] result in
            guard let self else { return }
            
            defer { UIBlockingProgressHUD.dismiss() }
            
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                print("✅ [ImagesListViewController.imageListCellDidTapLike]: Лайк успешно изменён")
            case .failure(let error):
                print("❌ [ImagesListViewController.imageListCellDidTapLike]: Ошибка изменения лайка:", error)
                // TODO: Показать ошибку с использованием UIAlertController
            }
        }
    }
}
