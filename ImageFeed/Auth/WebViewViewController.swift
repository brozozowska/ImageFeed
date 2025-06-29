//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Сергей Розов on 07.06.2025.
//

import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(
        _ vc: WebViewViewController,
        didAuthenticateWithCode code: String
    )
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {

    // MARK: - Constants
    private enum WebViewConstants {
        static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
        static let backButtonImageName = "Backward"
    }
    
    // MARK: - UI Elements
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.backgroundColor = .ypWhite
        webView.isOpaque = false
        return webView
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.tintColor = .ypBlack
        return progressView
    }()
    
    // MARK: - Public Properties
    weak var delegate: WebViewViewControllerDelegate?
    
    // MARK: - Private Properties
    private var estimatedProgressObservation: NSKeyValueObservation?

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        addSubviews()
        setupLayout()
        loadAuthView()
        configureBackButton()
        webView.navigationDelegate = self
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _, _ in
                 guard let self else { return }
                 self.updateProgress()
             }
        )
    }
    
    // MARK: - UI Setup
    private func addSubviews() {
        [
            webView,
            progressView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func configureBackButton() {
        let backButton = UIBarButtonItem(
            image: UIImage(named: WebViewConstants.backButtonImageName),
            style: .plain,
            target: self,
            action: #selector(didTapBackButton)
        )
        backButton.tintColor = .ypBlack
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    // MARK: - Load Authorization Page
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            print("❌ [WebViewViewController.loadAuthView]: Failure - не удалось создать URLComponents из строки: \(WebViewConstants.unsplashAuthorizeURLString)")
            return
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        guard let url = urlComponents.url else {
            print("❌ [WebViewViewController.loadAuthView]: Failure - не удалось получить URL из URLComponents: \(urlComponents)")
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    // MARK: - Actions
    @objc private func didTapBackButton() {
        delegate?.webViewViewControllerDidCancel(self)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - WKNavigationDelegate
extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    func code(from navigationAction: WKNavigationAction) -> String? {
        guard let url = navigationAction.request.url else {
            print("❌ [WebViewViewController.code]: Failure - не удалось извлечь URL из navigationAction")
            return nil
        }
        
        if
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            print("🔄 [WebViewViewController.code]: Переход на URL: \(url.absoluteString)")
            print("✅ [WebViewViewController.code]: Success - код авторизации получен: \(codeItem)")
            return codeItem.value
        } else {
            print("🔄 [WebViewViewController.code]: Переход на URL: \(url.absoluteString)")
            return nil
        }
    }
}
