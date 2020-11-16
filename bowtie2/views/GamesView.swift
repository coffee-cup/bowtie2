//
//  GamesView.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-15.
//

import SwiftUI

struct GamesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: Game.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Game.created, ascending: true)],
        animation: .default)
    private var games: FetchedResults<Game>
    
    var body: some View {
        List {
            ForEach(games, id: \.self) { game in
                HStack {
                    Text(game.name!)
                    Spacer()
                    Text("\(game.numPlayers()) players")
                }
            }
        }
    }
}

struct GamesView_Previews: PreviewProvider {
    static var previews: some View {
        GamesView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
