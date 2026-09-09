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

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
