//
//  bowtie2Tests.swift
//  bowtie2Tests
//
//  Created by Jake Runzer on 2020-11-14.
//

import CoreData
import XCTest
@testable import bowtie2

class bowtie2Tests: XCTestCase {
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        context = PersistenceController(inMemory: true).container.viewContext
    }

    @MainActor
    func testLiveActivityContentStateUsesCurrentGameScores() throws {
        let game = Game.createGame(context: context, name: "Test")
        let alice = Player.createPlayer(context: context, name: "Alice", colour: "FF0000")
        let bob = Player.createPlayer(context: context, name: "Bob", colour: "00FF00")

        _ = PlayerScore.createPlayerScore(context: context, game: game, player: alice, history: [10, 20])
        _ = PlayerScore.createPlayerScore(context: context, game: game, player: bob, history: [5])

        let state = LiveActivityManager.contentState(from: game)

        XCTAssertEqual(state.totalPlayers, 2)
        XCTAssertEqual(state.roundCount, 2)
        XCTAssertEqual(state.players.map(\.name), ["Alice", "Bob"])
        XCTAssertEqual(state.players.map(\.colorHex), ["FF0000", "00FF00"])
        XCTAssertEqual(state.players.map(\.score), [30, 5])
    }

    @MainActor
    func testLiveActivityContentStateFollowsLowestScoreSort() throws {
        let game = Game.createGame(context: context, name: "Test")
        game.winnerSort = .scoreLowest
        let alice = Player.createPlayer(context: context, name: "Alice", colour: "FF0000")
        let bob = Player.createPlayer(context: context, name: "Bob", colour: "00FF00")

        _ = PlayerScore.createPlayerScore(context: context, game: game, player: alice, history: [10, 20])
        _ = PlayerScore.createPlayerScore(context: context, game: game, player: bob, history: [5])

        let state = LiveActivityManager.contentState(from: game)

        XCTAssertEqual(state.players.map(\.name), ["Bob", "Alice"])
        XCTAssertEqual(state.players.map(\.score), [5, 30])
    }
}
