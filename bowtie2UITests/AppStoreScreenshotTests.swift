import XCTest

final class AppStoreScreenshotTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
    }

    func testLightScreenshots() {
        let app = launch(style: "Light")
        XCTAssertTrue(app.staticTexts["Racko 🎲"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.staticTexts["Nickels"].exists)
        XCTAssertTrue(app.staticTexts["Canasta"].exists)
        capture("03-games")

        app.staticTexts["Go Fish 🐠"].tap()
        XCTAssertTrue(app.buttons["scorePlayer.Jake"].waitForExistence(timeout: 5))
        for score in ["1805", "1475", "1120"] {
            XCTAssertTrue(app.staticTexts[score].exists)
        }
        capture("01-leaderboard")

        app.buttons["scorePlayer.Aleesha"].tap()
        XCTAssertTrue(app.navigationBars["Enter Score for Aleesha"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["score.key.9"].exists)
        capture("02-score-entry")
    }

    func testDarkCreationScreenshot() {
        let app = launch(style: "Dark")
        XCTAssertTrue(app.buttons["Create Game"].waitForExistence(timeout: 15))
        app.buttons["Create Game"].tap()
        let name = app.textFields["Canasta"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.tap()
        name.typeText("The Game\n")
        for player in ["Aleesha", "Gab", "Jake", "Macaroni"] {
            let toggle = app.switches["Include player \(player)"]
            XCTAssertTrue(toggle.waitForExistence(timeout: 5))
            toggle.tap()
        }
        XCTAssertFalse(app.keyboards.firstMatch.exists)
        XCTAssertTrue(app.buttons["Create"].isEnabled)
        capture("04-create-game")
    }

    func testNormalLaunchDoesNotContainScreenshotGames() {
        let app = XCUIApplication()
        app.launchArguments = ["-showWelcome", "NO", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        XCTAssertTrue(app.buttons["Create First Game"].waitForExistence(timeout: 15))
        XCTAssertFalse(app.staticTexts["Go Fish 🐠"].exists)
    }

    private func launch(style: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "--app-store-screenshots",
            "-AppleLanguages", "(en)", "-AppleLocale", "en_US",
            "-AppleInterfaceStyle", style,
            "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryM"
        ]
        if style == "Dark" {
            app.launchArguments.append("--screenshot-dark")
        }
        app.launchEnvironment["TZ"] = "UTC"
        app.launch()
        return app
    }

    private func capture(_ name: String) {
        // XCTest waits for UI idleness; also let sheet presentation and material effects settle.
        Thread.sleep(forTimeInterval: 1)
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "appstore-\(name)"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
