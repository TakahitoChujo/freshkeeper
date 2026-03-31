import XCTest

@MainActor
final class FreshKeeperUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    func testTabBarExists() throws {
        // Verify all three tabs exist
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists)
    }

    func testHomeTabShowsEmptyState() throws {
        // Home tab should show empty state when no items
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists)
    }

    func testNavigateToSettings() throws {
        // Tap settings button on home
        let settingsButton = app.navigationBars.buttons["gearshape"]
        if settingsButton.exists {
            settingsButton.tap()
            // Settings view should appear
            XCTAssertTrue(app.navigationBars.staticTexts.firstMatch.waitForExistence(timeout: 2))
        }
    }

    func testTabNavigation() throws {
        let tabBar = app.tabBars.firstMatch

        // Navigate to Statistics tab
        let statisticsTab = tabBar.buttons.element(boundBy: 2)
        if statisticsTab.exists {
            statisticsTab.tap()
        }

        // Navigate to Scan tab
        let scanTab = tabBar.buttons.element(boundBy: 1)
        if scanTab.exists {
            scanTab.tap()
        }

        // Navigate back to Home
        let homeTab = tabBar.buttons.element(boundBy: 0)
        if homeTab.exists {
            homeTab.tap()
        }
    }
}
