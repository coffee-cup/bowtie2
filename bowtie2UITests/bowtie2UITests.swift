//
//  bowtie2UITests.swift
//  bowtie2UITests
//
//  Created by Jake Runzer on 2020-11-14.
//

import XCTest

@MainActor
class bowtie2UITests: XCTestCase {

    override func setUp() async throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testScoreCalculatorReturnsResultToScoreEntry() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()

        if app.buttons["Get Started"].waitForExistence(timeout: 2) {
            app.buttons["Get Started"].tap()
        }

        let suffix = String(UUID().uuidString.prefix(6))
        let playerName = "Calculator Player \(suffix)"
        let gameName = "Calculator Game \(suffix)"

        app.tabBars.buttons["Players"].tap()

        let createPlayerButton = app.buttons["Create Player"]
        if createPlayerButton.waitForExistence(timeout: 2) {
            createPlayerButton.tap()
        } else {
            XCTAssertTrue(app.buttons["Add Player"].waitForExistence(timeout: 2))
            app.buttons["Add Player"].tap()
        }

        let playerNameField = app.textFields["Player name"]
        XCTAssertTrue(playerNameField.waitForExistence(timeout: 2))
        playerNameField.tap()
        playerNameField.typeText(playerName)
        app.buttons["Create"].tap()

        app.tabBars.buttons["Games"].tap()

        let createFirstGameButton = app.buttons["Create First Game"]
        if createFirstGameButton.waitForExistence(timeout: 2) {
            createFirstGameButton.tap()
        } else {
            XCTAssertTrue(app.buttons["Create Game"].waitForExistence(timeout: 2))
            app.buttons["Create Game"].tap()
        }

        let gameNameField = app.textFields["Canasta"]
        XCTAssertTrue(gameNameField.waitForExistence(timeout: 2))
        gameNameField.tap()
        gameNameField.typeText(gameName)

        let playerToggle = app.switches["Include player \(playerName)"]
        XCTAssertTrue(playerToggle.waitForExistence(timeout: 2))
        playerToggle.tap()
        app.buttons["Create"].tap()

        let gameTitle = app.staticTexts[gameName]
        XCTAssertTrue(gameTitle.waitForExistence(timeout: 2))
        gameTitle.tap()

        let playerCard = app.staticTexts[playerName]
        XCTAssertTrue(playerCard.waitForExistence(timeout: 2))
        playerCard.tap()

        app.buttons["Calculator"].tap()

        XCTAssertTrue(app.navigationBars["Calculate Score"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["0"].exists)
        XCTAssertFalse(app.staticTexts["Expression 0"].exists)

        let emptyCalculatorScreenshot = XCTAttachment(screenshot: app.screenshot())
        emptyCalculatorScreenshot.name = "Calculator layout without duplicate history"
        emptyCalculatorScreenshot.lifetime = .keepAlways
        add(emptyCalculatorScreenshot)

        app.buttons["calculator.key.1"].tap()
        XCTAssertTrue(app.staticTexts["1"].exists)
        XCTAssertFalse(app.staticTexts["Expression 1"].exists)
        app.buttons["calculator.key.4"].tap()
        app.buttons["calculator.key.add"].tap()
        app.buttons["calculator.key.2"].tap()
        app.buttons["calculator.key.3"].tap()
        app.buttons["calculator.key.subtract"].tap()
        app.buttons["calculator.key.8"].tap()

        XCTAssertTrue(app.staticTexts["Expression 14 + 23 − 8"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["29"].exists)

        app.buttons["calculator.key.delete"].tap()
        XCTAssertTrue(app.staticTexts["Expression 14 + 23 −"].waitForExistence(timeout: 2))
        app.buttons["calculator.key.delete"].tap()
        XCTAssertTrue(app.staticTexts["Expression 14 + 23"].waitForExistence(timeout: 2))
        app.buttons["calculator.key.4"].tap()
        XCTAssertTrue(app.staticTexts["Expression 14 + 234"].waitForExistence(timeout: 2))
        app.buttons["calculator.key.delete"].tap()
        XCTAssertTrue(app.staticTexts["Expression 14 + 23"].waitForExistence(timeout: 2))
        app.buttons["calculator.key.delete"].tap()
        XCTAssertTrue(app.staticTexts["Expression 14 + 2"].waitForExistence(timeout: 2))

        app.buttons["calculator.key.3"].tap()
        app.buttons["calculator.key.subtract"].tap()
        app.buttons["calculator.key.8"].tap()

        let calculatorScreenshot = XCTAttachment(screenshot: app.screenshot())
        calculatorScreenshot.name = "Score calculator on iPhone 17"
        calculatorScreenshot.lifetime = .keepAlways
        add(calculatorScreenshot)

        app.buttons["calculator.key.enter"].tap()

        XCTAssertTrue(app.navigationBars["Enter Score for \(playerName)"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["29"].exists)

        let returnedValueScreenshot = XCTAttachment(screenshot: app.screenshot())
        returnedValueScreenshot.name = "Calculated score returned to score entry"
        returnedValueScreenshot.lifetime = .keepAlways
        add(returnedValueScreenshot)

        XCTContext.runActivity(named: "Commit the calculated score and reopen the saved game") { _ in
            app.buttons["Go"].tap()
            XCTAssertTrue(app.buttons["scorePlayer.\(playerName)"].waitForExistence(timeout: 5))
            XCTAssertTrue(app.staticTexts["29"].exists)
            attachScreenshot(app, name: "Calculated score committed to scoreboard")

            app.terminate()
            app.launch()
            app.tabBars.buttons["Games"].tap()
            XCTAssertTrue(app.staticTexts[gameName].waitForExistence(timeout: 5))
            app.staticTexts[gameName].tap()
            let savedPlayer = app.buttons["scorePlayer.\(playerName)"]
            XCTAssertTrue(savedPlayer.waitForExistence(timeout: 5))
            XCTAssertTrue(app.staticTexts["29"].exists)
            attachScreenshot(app, name: "Saved score after app relaunch")

            savedPlayer.press(forDuration: 1)
            XCTAssertTrue(app.buttons["View History"].waitForExistence(timeout: 5))
            app.buttons["View History"].tap()
            XCTAssertTrue(app.navigationBars["Score history for \(playerName)"].waitForExistence(timeout: 5))
            XCTAssertEqual(app.cells.count, 1)
            XCTAssertTrue(app.cells.staticTexts["29"].exists)
            attachScreenshot(app, name: "Saved score independently visible in history")
        }

        XCTContext.runActivity(named: "Cancel an entry, save a negative turn, and undo through history") { _ in
            app.buttons["Done"].tap()
            let card = app.buttons["scorePlayer.\(playerName)"]
            card.tap()
            app.buttons["score.key.9"].tap()
            app.buttons["Close"].tap()
            XCTAssertTrue(card.waitForExistence(timeout: 5))
            XCTAssertTrue(app.staticTexts["29"].exists)

            card.tap()
            app.buttons["score.key.1"].tap()
            app.buttons["score.key.0"].tap()
            app.buttons["score.negative"].tap()
            app.buttons["Go"].tap()
            XCTAssertTrue(card.waitForExistence(timeout: 5))
            XCTAssertTrue(app.staticTexts["19"].exists)
            XCTAssertTrue(app.otherElements["game.graph"].exists)
            attachScreenshot(app, name: "Graph after positive and negative turns")

            app.terminate()
            app.launch()
            app.tabBars.buttons["Games"].tap()
            XCTAssertTrue(app.staticTexts[gameName].waitForExistence(timeout: 5))
            app.staticTexts[gameName].tap()
            XCTAssertTrue(card.waitForExistence(timeout: 5))
            XCTAssertTrue(app.staticTexts["19"].exists)
            card.press(forDuration: 1)
            app.buttons["View History"].tap()
            XCTAssertTrue(app.navigationBars["Score history for \(playerName)"].waitForExistence(timeout: 5))
            XCTAssertEqual(app.cells.count, 2)
            let negativeTurn = app.cells.containing(.staticText, identifier: "-10").firstMatch
            XCTAssertTrue(negativeTurn.exists)
            negativeTurn.swipeLeft()
            app.buttons["Delete"].tap()
            XCTAssertEqual(app.cells.count, 1)
            XCTAssertTrue(app.cells.staticTexts["29"].exists)
            app.buttons["Done"].tap()
            XCTAssertTrue(app.staticTexts["29"].waitForExistence(timeout: 5))
            XCTAssertFalse(app.otherElements["game.graph"].exists)

            app.terminate()
            app.launch()
            app.tabBars.buttons["Games"].tap()
            XCTAssertTrue(app.staticTexts[gameName].waitForExistence(timeout: 5))
            app.staticTexts[gameName].tap()
            XCTAssertTrue(card.waitForExistence(timeout: 5))
            XCTAssertTrue(app.staticTexts["29"].exists)
            card.press(forDuration: 1)
            app.buttons["View History"].tap()
            XCTAssertTrue(app.navigationBars["Score history for \(playerName)"].waitForExistence(timeout: 5))
            XCTAssertEqual(app.cells.count, 1)
            XCTAssertTrue(app.cells.staticTexts["29"].exists)
            attachScreenshot(app, name: "History deletion persists after relaunch")
        }
    }

    func testAppearancePreferencesPersistAfterRelaunch() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        if app.buttons["Get Started"].waitForExistence(timeout: 2) {
            app.buttons["Get Started"].tap()
        }
        app.tabBars.buttons["Settings"].tap()

        for name in ["Show graph", "Live Activities"] {
            let toggle = app.switches[name]
            XCTAssertTrue(toggle.waitForExistence(timeout: 5))
            // iOS 27 exposes the labelled row and its interactive switch separately.
            if toggle.value as? String == "1" { toggle.switches.firstMatch.tap() }
            XCTAssertEqual(toggle.value as? String, "0")
        }

        app.buttons["Theme"].tap()
        let theme = app.buttons["theme.Cherryblossoms"]
        XCTAssertTrue(theme.waitForExistence(timeout: 5))
        theme.tap()
        XCTAssertEqual(theme.value as? String, "Selected")
        attachScreenshot(app, name: "Selected free theme")
        app.navigationBars.buttons.element(boundBy: 0).tap()

        app.terminate()
        app.launch()
        app.tabBars.buttons["Settings"].tap()
        for name in ["Show graph", "Live Activities"] {
            XCTAssertEqual(app.switches[name].value as? String, "0")
        }
        app.buttons["Theme"].tap()
        XCTAssertTrue(theme.waitForExistence(timeout: 5))
        XCTAssertEqual(theme.value as? String, "Selected")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.buttons["✨ Premium ✨"].tap()
        XCTAssertTrue(app.staticTexts["✨ Bowtie Premium ✨"].waitForExistence(timeout: 5))
        app.buttons["Close"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))

        // Leave shared normal-launch tests with their default graph/activity preferences.
        for name in ["Show graph", "Live Activities"] {
            app.switches[name].switches.firstMatch.tap()
        }
    }

    func testAlternateAppIconPersistsAfterRelaunch() throws {
        #if targetEnvironment(simulator)
        let os = ProcessInfo.processInfo.operatingSystemVersion
        // These simulator runtimes do not complete alternate-icon requests.
        try XCTSkipIf(
            (os.majorVersion == 26 && os.minorVersion == 5 && os.patchVersion == 0)
                || (os.majorVersion == 27 && os.minorVersion == 0 && os.patchVersion == 0),
            "Alternate-icon requests do not complete on these simulator runtimes. Verify on a physical device."
        )
        #endif
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        if app.buttons["Get Started"].waitForExistence(timeout: 2) {
            app.buttons["Get Started"].tap()
        }
        app.tabBars.buttons["Settings"].tap()
        app.buttons["App icon"].tap()
        let icon = app.buttons["appIcon.cherryblossoms"]
        XCTAssertTrue(icon.waitForExistence(timeout: 5))
        icon.tap()
        attachScreenshot(app, name: "After alternate icon request")
        let iconSelected = NSPredicate(format: "value == %@", "Selected")
        expectation(for: iconSelected, evaluatedWith: icon)
        waitForExpectations(timeout: 60)
        if app.alerts.buttons["OK"].waitForExistence(timeout: 2) {
            app.alerts.buttons["OK"].tap()
        }
        attachScreenshot(app, name: "Selected alternate app icon")
        XCUIDevice.shared.press(.home)
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        if springboard.alerts.buttons["OK"].waitForExistence(timeout: 2) {
            springboard.alerts.buttons["OK"].tap()
        }
        XCTAssertTrue(springboard.icons["Bowtie"].waitForExistence(timeout: 5))
        attachScreenshot(springboard, name: "Alternate Bowtie icon on Home Screen")

        app.terminate()
        app.launch()
        app.tabBars.buttons["Settings"].tap()
        app.buttons["App icon"].tap()
        XCTAssertTrue(icon.waitForExistence(timeout: 5))
        XCTAssertEqual(icon.value as? String, "Selected")
        attachScreenshot(app, name: "Alternate icon restored after relaunch")
    }

    func testManualPlayerOrderDragSaveCancelAndReopen() throws {
        let app = XCUIApplication()
        app.launch()
        if app.buttons["Get Started"].waitForExistence(timeout: 2) {
            app.buttons["Get Started"].tap()
        }

        let suffix = String(UUID().uuidString.prefix(4))
        let names = ["Ava", "Ben", "Cal"].map { "\($0) \(suffix)" }
        let gameName = "Order \(suffix)"
        for name in names {
            app.tabBars.buttons["Players"].tap()
            let firstPlayer = app.buttons["Create Player"]
            if firstPlayer.exists { firstPlayer.tap() }
            else { app.buttons["Add Player"].tap() }
            let field = app.textFields["Player name"]
            XCTAssertTrue(field.waitForExistence(timeout: 3))
            field.tap()
            field.typeText(name)
            app.buttons["Create"].tap()
        }

        app.tabBars.buttons["Games"].tap()
        if app.buttons["Create First Game"].exists { app.buttons["Create First Game"].tap() }
        else { app.buttons["Create Game"].tap() }
        let gameField = app.textFields["Canasta"]
        XCTAssertTrue(gameField.waitForExistence(timeout: 3))
        gameField.tap()
        gameField.typeText(gameName + "\n")
        for name in names {
            let toggle = app.switches["Include player \(name)"]
            for _ in 0..<8 where !toggle.isHittable {
                app.swipeUp()
            }
            XCTAssertTrue(toggle.waitForExistence(timeout: 3))
            toggle.tap()
        }
        app.buttons["Create"].tap()
        XCTAssertTrue(app.staticTexts[gameName].waitForExistence(timeout: 3))
        app.staticTexts[gameName].tap()

        assertScoreboardOrder(names, in: app)
        XCTAssertFalse(app.buttons["playerOrder.reorder"].exists)
        selectPlayerOrder("Manual", in: app)
        enterPlayerReorder(in: app)
        for _ in 0..<3 {
            dragPlayer(names[2], before: names[0], in: app)
            dragPlayer(names[1], before: names[2], in: app)
            dragPlayer(names[0], before: names[1], in: app)
        }
        app.buttons["Cancel"].tap()
        assertScoreboardOrder(names, in: app)

        enterPlayerReorder(in: app)
        dragPlayer(names[2], before: names[0], in: app)
        dragPlayer(names[1], before: names[2], in: app)
        attachScreenshot(app, name: "Player order while dragging")
        app.buttons["playerOrder.save"].tap()
        let manual = [names[1], names[2], names[0]]
        assertScoreboardOrder(manual, in: app)

        app.buttons["scorePlayer.\(names[0])"].tap()
        XCTAssertTrue(app.buttons["score.key.9"].waitForExistence(timeout: 3))
        app.buttons["score.key.9"].tap()
        app.buttons["Go"].tap()
        assertScoreboardOrder(manual, in: app)
        attachScreenshot(app, name: "Manual scoreboard after scoring")

        selectPlayerOrder("By Score", in: app)
        XCTAssertFalse(app.buttons["playerOrder.reorder"].exists)
        assertScoreboardOrder(names, in: app)
        selectPlayerOrder("Manual", in: app)
        assertScoreboardOrder(manual, in: app)

        app.terminate()
        app.launch()
        app.tabBars.buttons["Games"].tap()
        XCTAssertTrue(app.staticTexts[gameName].waitForExistence(timeout: 3))
        app.staticTexts[gameName].tap()
        assertScoreboardOrder(manual, in: app)

        app.terminate()
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        app.tabBars.buttons["Games"].tap()
        XCTAssertTrue(app.staticTexts[gameName].waitForExistence(timeout: 3))
        app.staticTexts[gameName].tap()
        enterPlayerReorder(in: app)
        XCTAssertTrue(app.buttons["playerOrder.save"].isHittable)
        attachScreenshot(app, name: "Player order at largest accessibility text size")
        app.buttons["Cancel"].tap()
    }

    private func enterPlayerReorder(in app: XCUIApplication) {
        XCTAssertTrue(app.buttons["playerOrder.reorder"].waitForExistence(timeout: 3))
        app.buttons["playerOrder.reorder"].tap()
        XCTAssertTrue(app.buttons["playerOrder.save"].waitForExistence(timeout: 3))
    }

    private func selectPlayerOrder(_ order: String, in app: XCUIApplication) {
        app.buttons["game.settings"].tap()
        let picker = app.buttons["playerOrder.picker"]
        XCTAssertTrue(picker.waitForExistence(timeout: 3))
        picker.tap()
        app.buttons[order].tap()
        attachScreenshot(app, name: "Player order in Game Settings")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.buttons["game.settings"].waitForExistence(timeout: 3))
    }

    private func dragPlayer(_ name: String, before target: String, in app: XCUIApplication) {
        let sourceCell = app.cells.containing(.any, identifier: "reorderPlayer.\(name)").firstMatch
        let targetCell = app.cells.containing(.any, identifier: "reorderPlayer.\(target)").firstMatch
        XCTAssertTrue(sourceCell.exists)
        XCTAssertTrue(targetCell.exists)
        sourceCell.coordinate(withNormalizedOffset: CGVector(dx: 0.94, dy: 0.5))
            .press(forDuration: 0.1,
                   thenDragTo: targetCell.coordinate(withNormalizedOffset: CGVector(dx: 0.94, dy: 0.5)),
                   withVelocity: .slow,
                   thenHoldForDuration: 0.1)
        XCTAssertLessThan(sourceCell.frame.midY, targetCell.frame.midY)
    }

    private func assertScoreboardOrder(_ names: [String], in app: XCUIApplication, file: StaticString = #filePath, line: UInt = #line) {
        let cards = names.map { app.buttons["scorePlayer.\($0)"] }
        for card in cards { XCTAssertTrue(card.waitForExistence(timeout: 3), file: file, line: line) }
        for index in 1..<cards.count {
            XCTAssertLessThan(cards[index - 1].frame.midY, cards[index].frame.midY, file: file, line: line)
        }
    }

    private func attachScreenshot(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
