//
//  Player+CoreDataClass.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-15.
//
//

import Foundation
import CoreData

@objc(Player)
public class Player: NSManagedObject {
    static func createPlayer(context: NSManagedObjectContext, name: String, colour: String) -> Player {
        let newPlayer = Player(context: context)
        newPlayer.name = name
        newPlayer.colour = colour
        newPlayer.created = Date()
        
        return newPlayer
    }
}
