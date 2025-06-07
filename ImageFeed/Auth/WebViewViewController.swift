//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Сергей Розов on 07.06.2025.
//

import UIKit
import WebKit

final class WebViewViewController: UIViewController {

    // MARK: - UI Elements
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.backgroundColor = .ypWhite
        webView.isOpaque = false
        return webView
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
            webView
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
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
