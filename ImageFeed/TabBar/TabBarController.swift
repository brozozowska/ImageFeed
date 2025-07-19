//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Сергей Розов on 02.07.2025.
//

import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        )
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .profileTabActive),
            selectedImage: nil
        )
        self.viewControllers = [imagesListViewController, profileViewController]
        
    }
}
