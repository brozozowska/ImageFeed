//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Сергей Розов on 24.05.2025.
//

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    
    // MARK: - Constants
    private enum SingleImageViewConstants {
        enum Layout {
            static let backButtonSize: CGFloat = 48
            static let shareButtonSize: CGFloat = 50
            static let backButtonTopSpacing: CGFloat = 55
            static let backButtonLeadingSpacing: CGFloat = 8
            static let shareButtonBottomSpacing: CGFloat = -17
        }
    }
    
    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "Backward"), for: .normal)
        return button
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "Share"), for: .normal)
        return button
    }()
    
    // MARK: - Public Properties
    var fullImageURL: URL?

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        
        scrollView.delegate = self
        
        addSubviews()
        setupLayout()
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        loadImage()
    }
    
    // MARK: - Setup Methods
    private func addSubviews() {
        [
            scrollView,
            backButton,
            shareButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        [imageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview($0)
        }
        
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: SingleImageViewConstants.Layout.backButtonTopSpacing),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SingleImageViewConstants.Layout.backButtonLeadingSpacing),
            backButton.widthAnchor.constraint(equalToConstant: SingleImageViewConstants.Layout.backButtonSize),
            backButton.heightAnchor.constraint(equalToConstant: SingleImageViewConstants.Layout.backButtonSize),
            
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: SingleImageViewConstants.Layout.shareButtonBottomSpacing),
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shareButton.widthAnchor.constraint(equalToConstant: SingleImageViewConstants.Layout.shareButtonSize),
            shareButton.heightAnchor.constraint(equalToConstant: SingleImageViewConstants.Layout.shareButtonSize)
        ])
    }
    
    // MARK: - Actions
    @objc private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapShareButton() {
        guard let image = imageView.image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    private func rescaleAndCenterImageInScrollView(imageSize: CGSize) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        
        view.layoutIfNeeded()
        
        let visibleRectSize = scrollView.bounds.size

        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height

        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))

        scrollView.setZoomScale(scale, animated: false)
        
        centerImage()
    }
    
    private func centerImage() {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let horizontalInset = max((scrollViewSize.width - imageViewSize.width) / 2, 0)
        let verticalInset = max((scrollViewSize.height - imageViewSize.height) / 2, 0)
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
    
    private func loadImage() {
        guard let url = fullImageURL else {
            assertionFailure("❌ [SingleImageViewController.loadImage]: fullImageURL отсутствует")
            return
        }
        
        UIBlockingProgressHUD.show()
        
        imageView.kf.setImage(with: url) { [weak self] result in
            guard let self else { return }
            
            defer { UIBlockingProgressHUD.dismiss() }
            
            switch result {
            case .success(let value):
                self.imageView.frame = CGRect(origin: .zero, size: value.image.size)
                self.scrollView.contentSize = value.image.size
                self.rescaleAndCenterImageInScrollView(imageSize: value.image.size)
            case .failure(let error):
                print("❌ [SingleImageViewController.loadImage]: Не удалось загрузить фото:", error)
                self.showError()
            }
        }
    }
    
    private func showError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Не надо", style: .cancel) { _ in }
        
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadImage()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(retryAction)
        
        present(alert, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}
