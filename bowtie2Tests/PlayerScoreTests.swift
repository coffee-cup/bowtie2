//
//  PlayerScoreTests.swift
//  bowtie2Tests
//

import XCTest
import CoreData
@testable import bowtie2

class PlayerScoreTests: XCTestCase {
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        let controller = PersistenceController(inMemory: true)
        context = controller.container.viewContext
    }

    // MARK: - Current Score Calculation

    func testCurrentScoreSum() throws {
        let game = Game.createGame(context: context, name: "Test")
        let player = Player.createPlayer(context: context, name: "Alice", colour: "FF0000")
        let score = PlayerScore.createPlayerScore(context: context, game: game, player: player, history: [10, 20, 30])

        XCTAssertEqual(score.currentScore, 60)
    }

    func testCurrentScoreWithNegatives() throws {
        let game = Game.createGame(context: context, name: "Test")
        let player = Player.createPlayer(context: context, name: "Alice", colour: "FF0000")
        let score = PlayerScore.createPlayerScore(context: context, game: game, player: player, history: [100, -30, 50, -20])

        XCTAssertEqual(score.currentScore, 100)
    }

    func testCurrentScoreEmpty() throws {
        let game = Game.createGame(context: context, name: "Test")
        let player = Player.createPlayer(context: context, name: "Alice", colour: "FF0000")
        let score = PlayerScore.createPlayerScore(context: context, game: game, player: player, history: [])

        XCTAssertEqual(score.currentScore, 0)
    }

    func testCurrentScoreSingleEntry() throws {
        let game = Game.createGame(context: context, name: "Test")
        let player = Player.createPlayer(context: context, name: "Alice", colour: "FF0000")
        let score = PlayerScore.createPlayerScore(context: context, game: game, player: player, history: [42])

        XCTAssertEqual(score.currentScore, 42)
    }

    // MARK: - Summed History (for graphs)

    func testSummedHistory() throws {
        let game = Game.createGame(context: context, name: "Test")
        let player = Player.createPlayer(context: context, name: "Alice", colour: "FF0000")
        let score = PlayerScore.createPlayerScore(context: context, game: game, player: player, history: [10, 20, 30])

        XCTAssertEqual(score.summedHistory, [10, 30, 60])
    }

    func testSummedHistoryWithNegatives() throws {
        let game = Game.createGame(context: context, name: "Test")
        let player = Player.createPlayer(context: context, name: "Alice", colour: "FF0000")
        let score = PlayerScore.createPlayerScore(context: context, game: game, player: player, history: [100, -30, 50])

        XCTAssertEqual(score.summedHistory, [100, 70, 120])
    }

    func testSummedHistoryEmpty() throws {
        let game = Game.createGame(context: context, name: "Test")
        let player = Player.createPlayer(context: context, name: "Alice", colour: "FF0000")
        let score = PlayerScore.createPlayerScore(context: context, game: game, player: player, history: [])

        XCTAssertEqual(score.summedHistory, [])
    }

    func testSummedHistorySingleEntry() throws {
        let game = Game.createGame(context: context, name: "Test")
        let player = Player.createPlayer(context: context, name: "Alice", colour: "FF0000")
        let score = PlayerScore.createPlayerScore(context: context, game: game, player: player, history: [50])

        XCTAssertEqual(score.summedHistory, [50])
    }

    // MARK: - Wrapped History

    func testWrappedHistoryReturnsEmptyForNil() throws {
        let game = Game.createGame(context: context, name: "Test")
        let player = Player.createPlayer(context: context, name: "Alice", colour: "FF0000")
        let score = PlayerScore(context: context)
        score.game = game
        score.player = player
        score.history = nil

        XCTAssertEqual(score.wrappedHistory, [])
        XCTAssertEqual(score.currentScore, 0)
    }
}
