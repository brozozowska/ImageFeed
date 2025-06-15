//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Сергей Розов on 15.06.2025.
//

import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Private Properties
    private let showAuthViewSegueIdentifier = "ShowAuthView"
    private let storage = OAuth2TokenStorage()
    
    // MARK: - Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = storage.token {
            print("✅ Токен найден: переход к экрану с изображениями")
            switchToTabBarController()
        } else {
            print("🔑 Токена нет: переход к авторизации")
            performSegue(withIdentifier: showAuthViewSegueIdentifier, sender: nil)
        }
    }
    ;
    // MARK: - Private Methods
    private func switchToTabBarController() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthViewSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers.first as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthViewSegueIdentifier)")
                return
            }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true) { [weak self] in
            self?.switchToTabBarController()
        }
    }
}
