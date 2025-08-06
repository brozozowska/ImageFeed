//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Сергей Розов on 04.08.2025.
//

@testable import ImageFeed
import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false

        app.launchArguments = ["UITEST"]
        app.launch()
    }

    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        
        
        loginTextField.tap()
        loginTextField.typeText(" \t")
        sleep(1)
        
        passwordTextField.typeText(" ")
        sleep(1)
        
        app.keyboards.buttons["Go"].tap()
                
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        let window = app.windows.element(boundBy: 0)
        let tablesQuery = app.tables
        
        window.swipeUp()
        
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        cellToLike.buttons["LikeButton"].tap()
        sleep(2)
        cellToLike.buttons["LikeButton"].tap()
        sleep(2)
        
        cellToLike.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1) // zoom in
        image.pinch(withScale: 0.5, velocity: -1)
        
        app.buttons["BackButton"].tap()
    }
    
    func testProfile() throws {
        sleep(2)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts[" "].exists)
        XCTAssertTrue(app.staticTexts[" "].exists)
        
        app.buttons["LogoutButton"].tap()
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
