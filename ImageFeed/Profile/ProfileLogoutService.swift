//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Сергей Розов on 16.07.2025.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    
    // MARK: - Singleton
    static let shared = ProfileLogoutService()
    private init() {}
    
    // MARK: - Public Methods
    func logout() {
        cleanCookies()
        print("✅ [ProfileLogoutService.logout]: Success - куки успешно удалены")
        OAuth2TokenStorage.shared.token = nil
        print("✅ [ProfileLogoutService.logout]: Success - токен успешно удалён")
        ProfileService.shared.clear()
        ProfileImageService.shared.clear()
        ImagesListService.shared.clear()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
