//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Сергей Розов on 15.06.2025.
//

import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Private Properties
    private let storage = OAuth2TokenStorage()
    private let splashViewImageName = "Vector"
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    // MARK: - UI Elements
    private lazy var splashViewImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: splashViewImageName)
        return imageView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        addSubviews()
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = storage.token {
            print("🔑 [SplashViewController.viewDidAppear]: Токен найден: получаем профиль и переходим к экрану с изображениями")
            fetchProfile(token: token)
        } else {
            print("🔑 [SplashViewController.viewDidAppear]: Токена нет: переход к авторизации")
            presentAuthViewController()
        }
    }
    
    // MARK: - Setup Methods
    private func addSubviews() {
        [
            splashViewImage
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            splashViewImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashViewImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    // MARK: - Private Methods
    private func presentAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(
            withIdentifier: "AuthViewController"
        ) as? AuthViewController else {
            assertionFailure("❌ [SplashViewController.presentAuthViewController]: Не удалось найти AuthViewController по ID")
            return
        }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    private func switchToTabBarController() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first else {
            assertionFailure("❌ [SplashViewController.switchToTabBarController]: Нет активной UIWindowScene")
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let tabBarController = storyboard.instantiateViewController(
            withIdentifier: "TabBarController"
        )
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true) { [weak self] in
            self?.switchToTabBarController()
        }
        guard let token = storage.token else { return }
        fetchProfile(token: token)
    }
    
    func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token: token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }
            switch result {
            case .success(let profile):
                let username = profile.username
                profileImageService.fetchProfileImageURL(username: username, token: token) { _ in
                    print("✅ [SplashViewController.fetchProfile]: Вызов метода получения аватара")
                }
                self.switchToTabBarController()
            case .failure:
                // TODO: [Sprint 11] Покажите ошибку получения профиля
                break
            }
        }
    }
}
