//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Сергей Розов on 01.08.2025.
//

import Foundation

// MARK: - Protocol
protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapLogout()
}

// MARK: - Presenter
final class ProfilePresenter: ProfilePresenterProtocol {
    
    // MARK: - Public Properties
    weak var view: ProfileViewViewControllerProtocol?
    
    // MARK: - Private Properties
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private var profileImageObserver: NSObjectProtocol?
    
    
    // MARK: - Initializers
    init(
        profileService: ProfileServiceProtocol = ProfileService.shared,
        profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared
    ) {
        self.profileService = profileService
        self.profileImageService = profileImageService
    }
    
    // MARK: - Lifecycle
    func viewDidLoad() {
        if let profile = profileService.profile {
            view?.updateProfileDetails(profile)
        }
        
        updateProfileInfo()
        observeAvatarChanges()
        updateAvatar()
    }
    
    // MARK: - Public Methods
    func didTapLogout() {
        view?.showLogoutAlert()
    }
    
    // MARK: - Private Methods
    private func updateProfileInfo() {
        guard let profile = profileService.profile else {
            print("⚠️ [ProfilePresenter.updateProfileInfo]: профиль отсутствует")
            return
        }
        
        print("✅ [ProfilePresenter.updateProfileInfo]: получен профиль: \(profile.name)")
        view?.updateProfileDetails(profile)
    }
    
    private func observeAvatarChanges() {
        profileImageObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.updateAvatar()
        }
    }
    
    private func updateAvatar() {
        guard let urlString = profileImageService.avatarURL,
              let url = URL(string: urlString) else {
            print ("⚠️ [ProfilePresenter.updateAvatar]: Некорректный URL: \(profileImageService.avatarURL ?? "nil")")
            return
        }
        view?.updateAvatar(with: url)
    }
}
