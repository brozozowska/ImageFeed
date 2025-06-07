//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Сергей Розов on 07.06.2025.
//

import UIKit

final class AuthViewController: UIViewController {
    
    // MARK: - Constants
    private enum LayoutConstants {
        static let authScreenLogoSize: CGFloat = 60
        static let buttonHeight: CGFloat = 48
        static let leadingPadding: CGFloat = 16
        static let trailingPadding: CGFloat = -16
        static let bottomPadding: CGFloat = -90
    }
    
    private enum TextConstants {
        static let authScreenLogoName = "Auth Screen Logo"
        static let buttonText = "Войти"
        static let backButtonName = "Backward"
    }
    
    private enum SegueIdentifier {
        static let showWebView = "ShowWebView"
    }
    
    // MARK: - UI Elements
    private lazy var authScreenLogo: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: TextConstants.authScreenLogoName)
        return imageView
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle(TextConstants.buttonText, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.setTitleColor(.ypBlack, for: .normal)
        button.backgroundColor = .ypWhite
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        addSubviews()
        setupLayout()
        configureBackButton()
    }
    
    // MARK: - Setup Methods
    private func addSubviews() {
        [
            authScreenLogo,
            loginButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            authScreenLogo.heightAnchor.constraint(equalToConstant: LayoutConstants.authScreenLogoSize),
            authScreenLogo.widthAnchor.constraint(equalToConstant: LayoutConstants.authScreenLogoSize),
            authScreenLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            authScreenLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            loginButton.heightAnchor.constraint(equalToConstant: LayoutConstants.buttonHeight),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: LayoutConstants.leadingPadding),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: LayoutConstants.trailingPadding),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: LayoutConstants.bottomPadding)
        ])
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: TextConstants.backButtonName)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: TextConstants.backButtonName)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .ypBlack
    }
    
    // MARK: - Actions
    @objc private func didTapLoginButton() {
        performSegue(withIdentifier: SegueIdentifier.showWebView, sender: self)
    }
}
