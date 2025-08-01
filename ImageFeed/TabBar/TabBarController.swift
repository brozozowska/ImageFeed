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
        
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        )
        
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
