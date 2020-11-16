//
//  Persistence.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-14.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        
        let jake = Player.createPlayer(context: viewContext, name: "Jake", colour: "FF00FF")
        let aleesha = Player.createPlayer(context: viewContext, name: "Aleesha", colour: "FFD700")
        let gab = Player.createPlayer(context: viewContext, name: "Gab", colour: "00CED1")
        let mum = Player.createPlayer(context: viewContext, name: "Mum", colour: "4169E1")
        let dad = Player.createPlayer(context: viewContext, name: "Dad", colour: "5216ff")
        
        let g1 = Game.createGame(context: viewContext, name: "🦃 3000")
        let s1 = PlayerScore.createPlayerScore(context: viewContext, game: g1, player: jake)
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "bowtie2")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
