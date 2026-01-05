//
//  GameTests.swift
//  bowtie2Tests
//

import XCTest
import CoreData
@testable import bowtie2

class GameTests: XCTestCase {
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        let controller = PersistenceController(inMemory: true)
        context = controller.container.viewContext
    }

    // MARK: - Winner Tests (Highest Score)

    func testWinnerWithHighestScore() throws {
        let game = Game.createGame(context: context, name: "Test")
        game.winnerSort = .scoreHighest

        let player1 = Player.createPlayer(context: context, name: "Alice", colour: "FF0000")
        let player2 = Player.createPlayer(context: context, name: "Bob", colour: "00FF00")

        PlayerScore.createPlayerScore(context: context, game: game, player: player1, history: [10, 20])
        PlayerScore.createPlayerScore(context: context, game: game, player: player2, history: [5, 10])

        XCTAssertEqual(game.winner?.wrappedName, "Alice")
        XCTAssertFalse(game.isTie)
    }

    func testWinnerWithLowestScore() throws {
        let game = Game.createGame(context: context, name: "Test")
        game.winnerSort = .scoreLowest

        let player1 = Player.createPlayer(context: context, name: "Alice", colour: "FF0000")
        let player2 = Player.createPlayer(context: context, name: "Bob", colour: "00FF00")

        PlayerScore.createPlayerScore(context: context, game: game, player: player1, history: [10, 20])
        PlayerScore.createPlayerScore(context: context, game: game, player: player2, history: [5, 10])

        XCTAssertEqual(game.winner?.wrappedName, "Bob")
        XCTAssertFalse(game.isTie)
    }

    // MARK: - Tie Detection

    func testTieDetection() throws {
        let game = Game.createGame(context: context, name: "Test")

        let player1 = Player.createPlayer(context: context, name: "Alice", colour: "FF0000")
        let player2 = Player.createPlayer(context: context, name: "Bob", colour: "00FF00")

        PlayerScore.createPlayerScore(context: context, game: game, player: player1, history: [15])
        PlayerScore.createPlayerScore(context: context, game: game, player: player2, history: [15])

        XCTAssertTrue(game.isTie)
        XCTAssertNil(game.winner)
    }

    func testTieWithLowestScoreMode() throws {
        let game = Game.createGame(context: context, name: "Test")
        game.winnerSort = .scoreLowest

        let player1 = Player.createPlayer(context: context, name: "Alice", colour: "FF0000")
        let player2 = Player.createPlayer(context: context, name: "Bob", colour: "00FF00")

        PlayerScore.createPlayerScore(context: context, game: game, player: player1, history: [10])
        PlayerScore.createPlayerScore(context: context, game: game, player: player2, history: [10])

        XCTAssertTrue(game.isTie)
        XCTAssertNil(game.winner)
    }

    // MARK: - Edge Cases

    func testNoPlayersReturnsNoWinner() throws {
        let game = Game.createGame(context: context, name: "Empty")

        XCTAssertNil(game.winner)
        XCTAssertTrue(game.isTie)
    }

    func testSinglePlayerIsWinner() throws {
        let game = Game.createGame(context: context, name: "Solo")
        let player = Player.createPlayer(context: context, name: "Solo", colour: "FF0000")
        PlayerScore.createPlayerScore(context: context, game: game, player: player, history: [100])

        XCTAssertEqual(game.winner?.wrappedName, "Solo")
        XCTAssertFalse(game.isTie)
    }

    func testNegativeScores() throws {
        let game = Game.createGame(context: context, name: "Test")
        game.winnerSort = .scoreHighest

        let player1 = Player.createPlayer(context: context, name: "Alice", colour: "FF0000")
        let player2 = Player.createPlayer(context: context, name: "Bob", colour: "00FF00")

        PlayerScore.createPlayerScore(context: context, game: game, player: player1, history: [-10])
        PlayerScore.createPlayerScore(context: context, game: game, player: player2, history: [-20])

        XCTAssertEqual(game.winner?.wrappedName, "Alice") // -10 > -20
    }

    // MARK: - Max Entries

    func testMaxNumberOfEntries() throws {
        let game = Game.createGame(context: context, name: "Test")

        let player1 = Player.createPlayer(context: context, name: "Alice", colour: "FF0000")
        let player2 = Player.createPlayer(context: context, name: "Bob", colour: "00FF00")

        PlayerScore.createPlayerScore(context: context, game: game, player: player1, history: [1, 2, 3, 4])
        PlayerScore.createPlayerScore(context: context, game: game, player: player2, history: [1, 2])

        XCTAssertEqual(game.maxNumberOfEntries, 4)
    }

    func testMaxNumberOfEntriesEmpty() throws {
        let game = Game.createGame(context: context, name: "Empty")
        XCTAssertEqual(game.maxNumberOfEntries, 0)
    }
}
