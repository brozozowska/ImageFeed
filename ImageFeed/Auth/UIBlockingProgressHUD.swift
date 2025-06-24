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
        return UIApplication.shared.windows.first
    }
    
    private static var isShown = false
    
    static var isVisible: Bool {
        return isShown
    }
    
    static func show() {
        guard !isShown else { return }
        isShown = true
        window?.isUserInteractionEnabled = false
        print("🔒 Экран заблокирован")
        ProgressHUD.animate()
    }
    
    static func dismiss() {
        guard isShown else { return }
        isShown = false
        window?.isUserInteractionEnabled = true
        print("🔓 Экран разблокирован")
        ProgressHUD.dismiss()
    }
}
