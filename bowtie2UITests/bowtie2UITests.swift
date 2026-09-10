//
//  bowtie2UITests.swift
//  bowtie2UITests
//
//  Created by Jake Runzer on 2020-11-14.
//

import XCTest

class bowtie2UITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
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

        XCTAssertTrue(app.staticTexts["Expression 0"].waitForExistence(timeout: 2))
        app.buttons["calculator.key.1"].tap()
        XCTAssertTrue(app.staticTexts["Expression 1"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["1"].exists)
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
