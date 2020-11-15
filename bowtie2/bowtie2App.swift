//
//  bowtie2App.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-14.
//

import SwiftUI

@main
struct bowtie2App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
