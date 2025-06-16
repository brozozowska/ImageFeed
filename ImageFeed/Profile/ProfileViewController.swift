//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Сергей Розов on 21.05.2025.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Constants
    private enum ProfileViewConstants {
        enum Layout {
            static let avatarSize: CGFloat = 70
            static let buttonSize: CGFloat = 44
            static let topPadding: CGFloat = 76
            static let leadingPadding: CGFloat = 16
            static let trailingPadding: CGFloat = -16
            static let verticalSpacing: CGFloat = 8
        }
        
        enum Mock {
            static let imageName = "mockUserpic"
            static let name = "Екатерина Новикова"
            static let loginName = "@ekaterina_nov"
            static let description = "Hello, world!"
        }
    }
    
    // MARK: - UI Elements
    private lazy var avatarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ProfileViewConstants.Mock.imageName)
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = ProfileViewConstants.Mock.name
        label.textColor = .ypWhite
        label.font = .systemFont(ofSize: 23, weight: .bold)
        return label
    }()
    
    private lazy var loginNameLabel: UILabel = {
        let label = UILabel()
        label.text = ProfileViewConstants.Mock.loginName
        label.textColor = .ypGray
        label.font = .systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = ProfileViewConstants.Mock.description
        label.textColor = .ypWhite
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Exit"), for: .normal)
        button.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        addSubviews()
        setupLayout()
    }
    
    // MARK: - Setup Methods
    private func addSubviews() {
        [
            avatarImage,
            nameLabel,
            loginNameLabel,
            descriptionLabel,
            logoutButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            avatarImage.heightAnchor.constraint(equalToConstant: ProfileViewConstants.Layout.avatarSize),
            avatarImage.widthAnchor.constraint(equalToConstant: ProfileViewConstants.Layout.avatarSize),
            avatarImage.topAnchor.constraint(equalTo: view.topAnchor, constant: ProfileViewConstants.Layout.topPadding),
            avatarImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ProfileViewConstants.Layout.leadingPadding),
            
            logoutButton.heightAnchor.constraint(equalToConstant: ProfileViewConstants.Layout.buttonSize),
            logoutButton.widthAnchor.constraint(equalToConstant: ProfileViewConstants.Layout.buttonSize),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImage.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: ProfileViewConstants.Layout.trailingPadding),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImage.bottomAnchor, constant: ProfileViewConstants.Layout.verticalSpacing),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor),
            
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: ProfileViewConstants.Layout.verticalSpacing),
            loginNameLabel.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: ProfileViewConstants.Layout.verticalSpacing),
            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: logoutButton.trailingAnchor),
        ])
    }
    
    // MARK: - Actions
    @objc private func didTapLogoutButton() {
        // TODO: Реализовать выход
    }
    
}
