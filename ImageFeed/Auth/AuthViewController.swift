//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Сергей Розов on 07.06.2025.
//

import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    
    // MARK: - Constants
    private enum AuthViewConstants {
        enum Layout {
            static let authScreenLogoSize: CGFloat = 60
            static let buttonHeight: CGFloat = 48
            static let leadingPadding: CGFloat = 16
            static let trailingPadding: CGFloat = -16
            static let bottomPadding: CGFloat = -90
        }
        
        enum Text {
            static let authScreenLogoName = "Auth Screen Logo"
            static let buttonText = "Войти"
            static let backButtonName = "Backward"
        }
        
        enum SegueIdentifier {
            static let showWebView = "ShowWebView"
        }
    }
    
    // MARK: - UI Elements
    private lazy var authScreenLogo: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .authScreenLogo)
        return imageView
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle(AuthViewConstants.Text.buttonText, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.setTitleColor(.ypBlack, for: .normal)
        button.backgroundColor = .ypWhite
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(
            self,
            action: #selector(didTapLoginButton),
            for: .touchUpInside
        )
        return button
    }()
    
    // MARK: - Public Properties
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        addSubviews()
        setupLayout()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AuthViewConstants.SegueIdentifier.showWebView {
            guard let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("❌ Не удалось подготовиться к переходу \(AuthViewConstants.SegueIdentifier.showWebView)")
                return
            }
            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper)
            webViewViewController.presenter = webViewPresenter
            webViewPresenter.view = webViewViewController
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
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
            authScreenLogo.heightAnchor.constraint(equalToConstant: AuthViewConstants.Layout.authScreenLogoSize),
            authScreenLogo.widthAnchor.constraint(equalToConstant: AuthViewConstants.Layout.authScreenLogoSize),
            authScreenLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            authScreenLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            loginButton.heightAnchor.constraint(equalToConstant: AuthViewConstants.Layout.buttonHeight),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AuthViewConstants.Layout.leadingPadding),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: AuthViewConstants.Layout.trailingPadding),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: AuthViewConstants.Layout.bottomPadding)
        ])
    }
    
    // MARK: - Private Methods
    private func showAuthErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @objc private func didTapLoginButton() {
        guard !UIBlockingProgressHUD.isVisible else { return }
        performSegue(withIdentifier: AuthViewConstants.SegueIdentifier.showWebView, sender: self)
    }
}

// MARK: - WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(
        _ vc: WebViewViewController,
        didAuthenticateWithCode code: String
    ) {
        vc.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            UIBlockingProgressHUD.show()
            
            OAuth2Service.shared.fetchOAuthToken(code: code) { result in
                DispatchQueue.main.async {
                    UIBlockingProgressHUD.dismiss()
                }
                switch result {
                    case .success(let token):
                    print("✅ [AuthViewController.webViewViewController]: Success - токен получен: \(token)")
                    DispatchQueue.main.async {
                        self.delegate?.didAuthenticate(self)
                    }
                case .failure(let error):
                    print("❌ [AuthViewController.webViewViewController]: Failure - ошибка при получении токена: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.showAuthErrorAlert()
                    }
                }
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
