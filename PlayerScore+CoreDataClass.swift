//
//  PlayerScore+CoreDataClass.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-15.
//
//

import Foundation
import CoreData

@objc(PlayerScore)
public class PlayerScore: NSManagedObject {
    static func createPlayerScore(context: NSManagedObjectContext, game: Game, player: Player, history: [Int] = []) -> PlayerScore {
        let newScore = PlayerScore(context: context)
        newScore.game = game
        newScore.player = player
        newScore.history = history
        
        return newScore
    }
    
    var currentScore: Int {
        guard let history = self.history else {
            return 0
        }
        
        return history.reduce(0, { x, y in x + y })
    }
}
