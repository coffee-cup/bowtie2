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
    var currentScore: Int {
        get {
            guard let history = self.history else {
                return 0
            }
            
            return history.reduce(0, { x, y in x + y })
        }
    }
}
