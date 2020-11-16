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
    
    func numPlayers() -> Int {
        guard let scores = self.playerScores else {
            return 0
        }
        
        return scores.count
    }
}

extension Game {
//    var numPlayers: Int {
//        get {
//            return self.playerScores!.count
//        }
//    }
}
