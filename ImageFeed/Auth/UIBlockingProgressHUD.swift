//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Сергей Розов on 24.06.2025.
//

import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            assertionFailure("❌ [UIBlockingProgressHUD]: Нет активной UIWindowScene")
            return nil
        }
        return windowScene.windows.first
    }
    
    private static var isShown = false
    
    static var isVisible: Bool {
        return isShown
    }
    
    static func show() {
        guard !isShown else { return }
        isShown = true
        window?.isUserInteractionEnabled = false
        print("🔒 [UIBlockingProgressHUD.show]: Экран заблокирован")
        ProgressHUD.animate()
    }
    
    static func dismiss() {
        guard isShown else { return }
        isShown = false
        window?.isUserInteractionEnabled = true
        print("🔒 [UIBlockingProgressHUD.dismiss]: Экран разблокирован")
        ProgressHUD.dismiss()
    }
}
