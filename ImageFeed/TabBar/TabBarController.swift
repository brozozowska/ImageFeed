//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Сергей Розов on 02.07.2025.
//

import UIKit

final class TabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTapBar()
    }
    
    // MARK: - Setup Methods
    private func setupTapBar() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imagesListPresenter = ImagesListPresenter()
        let imagesListViewController = storyboard.instantiateViewController(identifier: "ImagesListViewController") { coder in
            ImagesListViewController(coder: coder, presenter: imagesListPresenter)
        }
        
        let profilePresenter = ProfilePresenter()
        let profileViewController = ProfileViewController(presenter: profilePresenter)
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .profileTabActive),
            selectedImage: nil
        )
        self.viewControllers = [
            imagesListViewController,
            profileViewController
        ]
    }
}
