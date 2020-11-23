//
//  Game+CoreDataClass.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-15.
//
//

import Foundation
import CoreData

@objc(Game)
public class Game: NSManagedObject {
    static func createGame(context: NSManagedObjectContext, name: String) -> Game {
        let newGame = Game(context: context)
        newGame.name = name
        newGame.created = Date()
        newGame.playerScores = NSSet()
        
        return newGame
    }
    
    static func createGameWithPlayers(context: NSManagedObjectContext, name: String, players: [Player]) -> Game {
        let game = Game.createGame(context: context, name: name)

        // Create player scores for each playexzr
        players.forEach({ player in
            PlayerScore.createPlayerScore(context: context, game: game, player: player)
        })
        
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
    
    public var scoresArray: [PlayerScore] {
        let set = playerScores as? Set<PlayerScore> ?? []
        return set.sorted {
            $0.currentScore > $1.currentScore
        }
    }
    
    public var winner: Player? {
        if scoresArray.count <= 0 {
            return nil
        }
        
        let values = scoresArray.map({ ps in ps.currentScore })
        
        if values.count != values.uniques.count {
            // There is a tie
            print("game is tie")
            return nil
        }
        
        return scoresArray[0].player
    }
}

extension Game {
    
}
