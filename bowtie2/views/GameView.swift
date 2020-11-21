//
//  GameView.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-21.
//

import SwiftUI

struct GameView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var game: Game
    
    var body: some View {
        NavigationView {
            Text(game.wrappedName)
                .navigationTitle(game.wrappedName)
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(game: PersistenceController.sampleGame)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
