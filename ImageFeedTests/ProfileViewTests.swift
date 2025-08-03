//
//  ProfileViewTests.swift
//  ImageFeedTests
//
//  Created by Сергей Розов on 03.08.2025.
//

@testable import ImageFeed
import XCTest

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var viewDidLoadCalled = false
    var didTapLogoutCalled = false
    
    var view: ProfileViewViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLogout() {
        didTapLogoutCalled = true
    }
}

final class ProfileViewControllerSpy: ProfileViewViewControllerProtocol {
    var updateProfileDetailsCalled = false
    var updateAvatarCalled = false
    var showLogoutAlertCalled = false
    
    var presenter: ProfilePresenterProtocol?
    
    var updatedProfile: Profile?
    var updatedAvatarURL: URL?
    
    func updateProfileDetails(_ profile: Profile) {
        updateProfileDetailsCalled = true
        updatedProfile = profile
    }
    
    func updateAvatar(with url: URL) {
        updateAvatarCalled = true
        updatedAvatarURL = url
    }
    
    func showLogoutAlert() {
        showLogoutAlertCalled = true
    }
}

final class ProfileServiceMock: ProfileServiceProtocol {
    var profile: Profile?
    
    init(profile: Profile) {
        self.profile = profile
    }
}

final class ProfileImageServiceMock: ProfileImageServiceProtocol {
    var avatarURL: String?
    
    init(avatarURL: String) {
        self.avatarURL = avatarURL
    }
}

final class ProfileTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        // given
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewControllerSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterUpdatesViewWithProfile() {
        // given
        let expectedProfile = Profile(
            username: "test_user",
            name: "Test User",
            loginName: "@test_user",
            bio: "Bio text"
        )
        
        let expectedAvatarURL = "https://example.com/avatar.jpg"
        
        let profileServiceMock = ProfileServiceMock(profile: expectedProfile)
        let profileImageServiceMock = ProfileImageServiceMock(avatarURL: expectedAvatarURL)
        
        let presenter = ProfilePresenter(
            profileService: profileServiceMock,
            profileImageService: profileImageServiceMock
        )
        
        let viewSpy = ProfileViewControllerSpy()
        presenter.view = viewSpy
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(viewSpy.updateProfileDetailsCalled)
        XCTAssertEqual(viewSpy.updatedProfile?.username, expectedProfile.username)
        XCTAssertEqual(viewSpy.updatedProfile?.name, expectedProfile.name)
        XCTAssertEqual(viewSpy.updatedProfile?.loginName, expectedProfile.loginName)
        XCTAssertEqual(viewSpy.updatedProfile?.bio, expectedProfile.bio)
        XCTAssertTrue(viewSpy.updateAvatarCalled)
        XCTAssertEqual(viewSpy.updatedAvatarURL?.absoluteString, expectedAvatarURL)
    }
    
    func testPresenterDidTapLogoutCallsShowLogoutAlert() {
        // given
        let presenter = ProfilePresenter()
        let viewSpy = ProfileViewControllerSpy()
        presenter.view = viewSpy
        
        // when
        presenter.didTapLogout()
        
        // then
        XCTAssertTrue(viewSpy.showLogoutAlertCalled)
    }
}
