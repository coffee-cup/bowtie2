import XCTest
import CoreData
@testable import bowtie2

final class PlayerOrderTests: XCTestCase {
    private var context: OrderTestContext!

    override func setUpWithError() throws {
        context = try makeContext()
    }

    override func tearDown() {
        context = nil
    }

    private func model(version: String? = nil) throws -> NSManagedObjectModel {
        let directory = try XCTUnwrap(Bundle(for: Game.self).url(forResource: "bowtie2", withExtension: "momd"))
        let url = version.map { directory.appendingPathComponent($0 + ".mom") } ?? directory
        return try XCTUnwrap(NSManagedObjectModel(contentsOf: url))
    }

    private func makeContext(version: String? = nil, url: URL? = nil) throws -> OrderTestContext {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: try model(version: version))
        try coordinator.addPersistentStore(
            ofType: url == nil ? NSInMemoryStoreType : NSSQLiteStoreType,
            configurationName: nil, at: url,
            options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        )
        let result = OrderTestContext(concurrencyType: .mainQueueConcurrencyType)
        result.persistentStoreCoordinator = coordinator
        result.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        return result
    }

    private func fixture() throws -> (Game, [PlayerScore]) {
        let game = Game.createGame(context: context, name: "Seating order")
        let scores = [("Alice", 30), ("Bob", 20), ("Charlie", 10)].map { name, points in
            PlayerScore.createPlayerScore(context: context, game: game,
                player: Player.createPlayer(context: context, name: name, colour: "FF0000"), history: [points])
        }
        try context.save()
        return (game, scores)
    }

    private func names(_ scores: [PlayerScore]) -> [String] {
        scores.compactMap { $0.player?.wrappedName }
    }

    func testDefaultAndFirstManualActivationCaptureCurrentRanking() throws {
        let (game, scores) = try fixture()
        XCTAssertEqual(game.playerOrder, .byScore)
        XCTAssertFalse(game.hasManualPlayerOrder)
        XCTAssertTrue(scores.allSatisfy { $0.manualPosition == nil && $0.orderingID != nil })
        game.winnerSort = .scoreLowest
        try game.savePlayerOrder(.manual)
        XCTAssertEqual(names(game.displayScoresArray), ["Charlie", "Bob", "Alice"])
        XCTAssertEqual(game.manualScoresArray.compactMap { $0.manualPosition?.intValue }, [0, 1, 2])
    }

    func testManualOrderSurvivesScoringUndoRenameAndModeChanges() throws {
        let (game, scores) = try fixture()
        try game.savePlayerOrder(.manual, draft: [scores[1], scores[2], scores[0]].map(\.objectID))
        scores[0].history?.append(100)
        XCTAssertEqual(game.displayScoresArray, [scores[1], scores[2], scores[0]])
        scores[0].history?.removeLast()
        scores[1].player?.name = "Zelda"
        XCTAssertEqual(game.displayScoresArray, [scores[1], scores[2], scores[0]])
        try game.savePlayerOrder(.byScore)
        XCTAssertEqual(game.displayScoresArray, scores)
        XCTAssertEqual(game.initialPlayerOrder, [scores[1], scores[2], scores[0]])
        try game.savePlayerOrder(.manual)
        XCTAssertEqual(game.displayScoresArray, [scores[1], scores[2], scores[0]])
    }

    @MainActor
    func testWinnerTieAndLiveActivityRemainRanked() throws {
        let (game, scores) = try fixture()
        try game.savePlayerOrder(.manual, draft: scores.reversed().map(\.objectID))
        XCTAssertEqual(game.winner, scores[0].player)
        XCTAssertEqual(game.scoresArray, scores)
        XCTAssertEqual(LiveActivityManager.contentState(from: game).players.map(\.name), ["Alice", "Bob", "Charlie"])
        game.winnerSort = .scoreLowest
        XCTAssertEqual(game.winner, scores[2].player)
        scores[1].history = [-20]
        scores[2].history = [-10]
        XCTAssertEqual(game.winner, scores[1].player)
        scores[2].history = [-20]
        XCTAssertTrue(game.isTie)
        XCTAssertNil(game.winner)
        game.winnerSort = .scoreHighest
        scores[0].history = [-20]
        XCTAssertTrue(game.isTie)
        XCTAssertNil(game.winner)
    }

    func testAdditionsAppendAlphabeticallyAndRemovalPreservesOrder() throws {
        let (game, scores) = try fixture()
        try game.savePlayerOrder(.manual, draft: scores.reversed().map(\.objectID))
        try game.savePlayerOrder(.byScore)
        let zoe = Player.createPlayer(context: context, name: "Zoe", colour: "FF0000")
        let dan = Player.createPlayer(context: context, name: "Dan", colour: "00FF00")
        game.addPlayers(context: context, players: [zoe, dan, dan])
        XCTAssertEqual(names(game.manualScoresArray), ["Charlie", "Bob", "Alice", "Dan", "Zoe"])
        game.removePlayer(context: context, player: try XCTUnwrap(scores[1].player))
        XCTAssertEqual(names(game.manualScoresArray), ["Charlie", "Alice", "Dan", "Zoe"])
        try game.savePlayerOrder(.manual)
        XCTAssertEqual(names(game.displayScoresArray), ["Charlie", "Alice", "Dan", "Zoe"])
    }

    func testDuplicationCopiesRememberedOrderWithFreshScoresAndIDs() throws {
        let (game, scores) = try fixture()
        try game.savePlayerOrder(.manual, draft: scores.reversed().map(\.objectID))
        for mode in PlayerOrder.allCases {
            try game.savePlayerOrder(mode)
            let copy = Game.duplicateGame(context: context, gameToDuplicate: game)
            XCTAssertEqual(copy.playerOrder, mode)
            XCTAssertEqual(names(copy.manualScoresArray), ["Charlie", "Bob", "Alice"])
            XCTAssertTrue(copy.activePlayerScores.allSatisfy { $0.wrappedHistory.isEmpty })
            XCTAssertTrue(Set(copy.activePlayerScores.compactMap(\.orderingID)).isDisjoint(with: scores.compactMap(\.orderingID)))
        }
    }

    func testDraftDoesNotMutateAndSaveReconcilesCurrentMembership() throws {
        let (game, scores) = try fixture()
        let draft = scores.reversed().map(\.objectID)
        XCTAssertEqual(game.playerOrder, .byScore)
        XCTAssertFalse(context.hasChanges)
        game.removePlayer(context: context, player: try XCTUnwrap(scores[1].player))
        let added = PlayerScore.createPlayerScore(context: context, game: game,
            player: Player.createPlayer(context: context, name: "Dan", colour: "FF0000"))
        try context.save()
        let unrelatedGame = Game.createGame(context: context, name: "Other game")
        let unrelated = PlayerScore.createPlayerScore(context: context, game: unrelatedGame,
            player: try XCTUnwrap(scores[0].player))
        try game.savePlayerOrder(.manual, draft: draft + [draft[0], unrelated.objectID])
        XCTAssertEqual(game.displayScoresArray, [scores[2], scores[0], added])
        XCTAssertNil(unrelated.manualPosition)
    }

    func testDuplicationHandlesRepeatedParticipationRecords() throws {
        let (game, scores) = try fixture()
        PlayerScore.createPlayerScore(context: context, game: game, player: try XCTUnwrap(scores[0].player))
        try game.savePlayerOrder(.manual)
        let copy = Game.duplicateGame(context: context, gameToDuplicate: game)
        XCTAssertEqual(names(copy.manualScoresArray), names(game.manualScoresArray))
        XCTAssertEqual(copy.activePlayerScores.count, 4)
    }

    func testFailedSaveRestoresOnlyOrderingAndCanRetry() throws {
        let (game, scores) = try fixture()
        scores[0].orderingID = nil
        try context.save()
        scores[0].history = [99]
        game.name = "Unsaved name"
        context.failSave = true
        let draft = scores.reversed().map(\.objectID)
        XCTAssertThrowsError(try game.savePlayerOrder(.manual, draft: draft))
        XCTAssertEqual(game.playerOrder, .byScore)
        XCTAssertTrue(scores.allSatisfy { $0.manualPosition == nil })
        XCTAssertNil(scores[0].orderingID)
        XCTAssertEqual(scores[0].history, [99])
        XCTAssertEqual(game.name, "Unsaved name")
        context.failSave = false
        try game.savePlayerOrder(.manual, draft: draft)
        XCTAssertEqual(game.displayScoresArray, scores.reversed())
        XCTAssertNotNil(scores[0].orderingID)
    }

    func testConflictingAndMissingPositionsHaveStableReadOnlyFallbacks() throws {
        let (game, scores) = try fixture()
        scores[0].manualPosition = 0
        scores[1].manualPosition = 0
        scores[0].orderingID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")
        scores[1].orderingID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")
        scores[2].orderingID = nil
        game.playerOrder = .manual
        try context.save()
        XCTAssertEqual(game.displayScoresArray, [scores[1], scores[0], scores[2]])
        XCTAssertEqual(game.displayScores(from: scores.reversed()), [scores[1], scores[0], scores[2]])
        XCTAssertFalse(context.hasChanges)
        XCTAssertNil(scores[2].manualPosition)
        XCTAssertNil(scores[2].orderingID)
    }

    func testEmptyAndSinglePlayerGames() throws {
        let game = Game.createGame(context: context, name: "Empty")
        try game.savePlayerOrder(.manual)
        XCTAssertTrue(game.displayScoresArray.isEmpty)
        XCTAssertNil(game.winner)
        let solo = PlayerScore.createPlayerScore(context: context, game: game,
            player: Player.createPlayer(context: context, name: "Solo", colour: "FF0000"))
        XCTAssertEqual(game.displayScoresArray, [solo])
        XCTAssertEqual(solo.manualPosition, 0)
        XCTAssertEqual(game.winner, solo.player)
    }

    func testOrderPersistsAfterClosingAndReopeningStore() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("order.sqlite")
        context = try makeContext(url: url)
        let (game, scores) = try fixture()
        try game.savePlayerOrder(.manual, draft: scores.reversed().map(\.objectID))
        let savedIDs = game.manualScoresArray.compactMap(\.orderingID)
        context.reset()
        let coordinator = try XCTUnwrap(context.persistentStoreCoordinator)
        for store in coordinator.persistentStores { try coordinator.remove(store) }
        context = try makeContext(url: url)
        let restored = try XCTUnwrap(Game.gameByName(context: context, name: "Seating order"))
        XCTAssertEqual(restored.playerOrder, .manual)
        XCTAssertEqual(names(restored.displayScoresArray), ["Charlie", "Bob", "Alice"])
        XCTAssertEqual(restored.manualScoresArray.compactMap(\.orderingID), savedIDs)
    }

    func testPreviousModelMigratesWithoutBackfillOrScoreChanges() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("legacy.sqlite")
        let legacy = try makeContext(version: "bowtie2", url: url)
        let game = NSEntityDescription.insertNewObject(forEntityName: "Game", into: legacy)
        game.setValue("Legacy", forKey: "name")
        let player = NSEntityDescription.insertNewObject(forEntityName: "Player", into: legacy)
        player.setValue("Alice", forKey: "name")
        let score = NSEntityDescription.insertNewObject(forEntityName: "PlayerScore", into: legacy)
        score.setValue(game, forKey: "game")
        score.setValue(player, forKey: "player")
        score.setValue([10, -3], forKey: "history")
        try legacy.save()
        legacy.reset()
        let coordinator = try XCTUnwrap(legacy.persistentStoreCoordinator)
        for store in coordinator.persistentStores { try coordinator.remove(store) }
        context = try makeContext(url: url)
        let migrated = try XCTUnwrap(Game.gameByName(context: context, name: "Legacy"))
        XCTAssertEqual(migrated.playerOrder, .byScore)
        let restored = try XCTUnwrap(migrated.scoresArray.first)
        XCTAssertEqual(restored.history, [10, -3])
        XCTAssertNil(restored.manualPosition)
        XCTAssertNil(restored.orderingID)
        XCTAssertFalse(context.hasChanges)
        try migrated.savePlayerOrder(.manual)
        XCTAssertEqual(restored.manualPosition, 0)
        XCTAssertNotNil(restored.orderingID)
    }

    func testRemoteContextPositionChangesUpdateOrdering() throws {
        let (game, scores) = try fixture()
        try game.savePlayerOrder(.manual)
        let other = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        other.persistentStoreCoordinator = context.persistentStoreCoordinator
        let moved = try XCTUnwrap(other.object(with: scores[2].objectID) as? PlayerScore)
        moved.manualPosition = -1
        try other.save()
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSUpdatedObjectsKey: [moved.objectID]], into: [context])
        context.processPendingChanges()
        XCTAssertEqual(game.displayScoresArray, [scores[2], scores[0], scores[1]])
    }
}

private final class OrderTestContext: NSManagedObjectContext, @unchecked Sendable {
    var failSave = false

    override func save() throws {
        if failSave { throw CocoaError(.persistentStoreSave) }
        try super.save()
    }
}
