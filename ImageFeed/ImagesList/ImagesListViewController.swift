//
//  ViewController.swift
//  ImageFeed
//
//  Created by Сергей Розов on 15.05.2025.
//

import UIKit
import Kingfisher

// MARK: - Protocol
protocol ImagesListViewControllerProtocol: AnyObject {
    func insertRows(at indexPaths: [IndexPath])
    func reloadRows(at indexPaths: [IndexPath])
    func performSegueToSingleImage(at indexPath: IndexPath, url: URL)
}

// MARK: - ImagesListViewController
final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    // MARK: - UI Elements
    // переменная используется только для тестов
     var tableView = UITableView()
    
    // MARK: - Private Properties
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var presenter: ImagesListPresenterProtocol!
    
    // MARK: - Initializers
    init?(coder: NSCoder, presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
        self.presenter.view = self
        self.presenter.viewDidLoad()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        tabBarController?.tabBar.isTranslucent = false
        tabBarController?.tabBar.backgroundColor = .ypBlack
 
        setupTableView()
        setupLayout()
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
        if segue.identifier == showSingleImageSegueIdentifier,
           let viewController = segue.destination as? SingleImageViewController,
           let indexPath = sender as? IndexPath {
            let photo = presenter?.photo(at: indexPath.row)
            viewController.fullImageURL = URL(string: photo!.largeImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - ImagesListViewControllerProtocol
    func insertRows(at indexPaths: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func reloadRows(at indexPaths: [IndexPath]) {
        tableView.reloadRows(at: indexPaths, with: .automatic)
    }
    
    func performSegueToSingleImage(at indexPath: IndexPath, url: URL) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectImage(at: indexPath.row)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        presenter.heightForImage(at: indexPath.row, tableViewWidth: tableView.bounds.width)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter.willDisplayCell(at: indexPath.row)
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.photosCount
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let photo = presenter.photo(at: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
                
        imageListCell.delegate = self
        
        imageListCell.placeholderImageView.image = UIImage(resource: .stub)
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
        
        imageListCell.dateLabel.text = presenter.formattedDate(at: indexPath.row)
        
        let likeImageName = photo.isLiked ? UIImage(resource: .favoritesActive) : UIImage(resource: .favoritesNoActive)
        imageListCell.likeButton.setImage(likeImageName, for: .normal)
        
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
        presenter.toggleLike(at: indexPath.row)
    }
}
