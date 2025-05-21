//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Сергей Розов on 21.05.2025.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    @IBOutlet private weak var avatarImage: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var loginNameLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction private func didTapLogoutButton() {
    }
    
}
