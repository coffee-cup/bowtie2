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
        
//        let values = scoresArray.map { $0.currentScore }
//        if values.similar().count > 0 {
//            // a tie
//            return nil
//        }
        
        return scoresArray[0].player
    }
}

extension Game {
    
}
