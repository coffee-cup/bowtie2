//
//  Game+CoreDataClass.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-15.
//
//

import Foundation
import CoreData

public enum SortOrder: Int, Equatable, CaseIterable {
    case scoreHighest = 0
    case scoreLowest = 1
    
    var stringValue: String {
        switch self {
        case .scoreHighest:
            return "Has Most Points"
        case.scoreLowest:
            return "Has Fewest Points"
        }
    }
}

@objc(Game)
public class Game: NSManagedObject {
    static func createGame(context: NSManagedObjectContext, name: String) -> Game {
        let newGame = Game(context: context)
        newGame.name = name
        newGame.created = Date()
        newGame.playerScores = NSSet()
        newGame.sortOrder = Int16(SortOrder.scoreHighest.rawValue)
        
        return newGame
    }
    
    static func createGameWithPlayers(context: NSManagedObjectContext, name: String, players: [Player]) -> Game {
        let game = Game.createGame(context: context, name: name)

        // Create player scores for each playexzr
        players.forEach({ player in
            context.refresh(player, mergeChanges: true)
            PlayerScore.createPlayerScore(context: context, game: game, player: player)
        })
        
        return game
    }
    
    static func duplicateGame(context: NSManagedObjectContext, gameToDuplicate: Game) -> Game {
        let players = gameToDuplicate.scoresArray.map({ score in score.player }).filter({ player in player != nil }) as! [Player]
        let game = Game.createGameWithPlayers(context: context, name: gameToDuplicate.wrappedName, players: players)
        return game
    }
    
    static func gameByName(context: NSManagedObjectContext, name: String) -> Game? {
        let request: NSFetchRequest<Game> = Game.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "name ==[c] %@", name)
        let games = try? context.fetch(request)
        return games?.first
    }
    
    public var wrappedName: String {
        return name ?? "Unnamed"
    }
    
    public var wrappedCreated: Date {
        return created ?? Date()
    }
    
    public var wrappedSortOrder: SortOrder {
        return SortOrder(rawValue: Int(sortOrder)) ?? .scoreHighest
    }
    
    public var scoresArray: [PlayerScore] {
        let set = playerScores as? Set<PlayerScore> ?? []
        return set.sorted {
            $0.currentScore > $1.currentScore
        }
    }
    
    public var sortedScoresArray: [PlayerScore] {
        switch wrappedSortOrder {
        case .scoreHighest:
            return scoresArray
        case.scoreLowest:
            return scoresArray.reversed()
        }
    }
    
    public var isTie: Bool {
        guard let maxScore = scoresArray.map({ p in p.currentScore }).max() else {
            return true
        }
        
        let numPlayersWithMax = scoresArray.filter { p in p.currentScore == maxScore }
        return numPlayersWithMax.count != 1
    }
    
    public var winner: Player? {
        if scoresArray.count <= 0 {
            return nil
        }
        
        if isTie {
            return nil
        }
        
        return sortedScoresArray[0].player
    }
    
    public var maxNumberOfEntries: Int {
        let entryCount = scoresArray.map({ playerScore in playerScore.history?.count ?? 0 })
        return entryCount.max() ?? 0
    }
    
    public var colourList: [String] {
        return scoresArray.map({ score in score.player?.wrappedColor ?? "000000" })
    }
}

extension Game {
    
}
