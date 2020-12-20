//
//  GamesView.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-15.
//

import SwiftUI

struct GamesListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: Game.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Game.created, ascending: false)],
        animation: .default)
    private var games: FetchedResults<Game>
    
    @State var isCreating = false
    @State var isDeleting = false
    
    @State private var deletingGame: Game? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(games, id: \.self) { game in
                        NavigationLink(destination: GameView(game: game)) {
                            GameCard(game: game)
                        }
                        .contextMenu {
                            Button(action: {
                                self.duplicateGame(game: game)
                            }) {
                                HStack {
                                    Text("Duplicate Game")
                                    Image(systemName: "doc.on.doc")
                                }
                            }
                            
                            Button(action: {
                                self.deletingGame = game
                                self.isDeleting = true
                            }) {
                                HStack {
                                    Text("Delete Game")
                                    Image(systemName: "trash")
                                }
                            }
                        }
                    }
                }
                .padding(.all)
            }
            .navigationBarTitle("Games", displayMode: .large)
            .toolbar {
                Button(action: {
                    self.isCreating = true
                }) {
                    Label("Create Game", systemImage: "plus")
                }
            }
            .sheet(isPresented: $isCreating) {
                CreateGame()

            }
            .alert(isPresented: $isDeleting) {
                        Alert(title: Text("Are you sure you want to delete this?"),
                              primaryButton: .destructive(Text("Delete")) {
                                if let game = self.deletingGame {
                                    self.deleteGame(game: game)
                                }
                        }, secondaryButton: .cancel())
                    }
        }
    }
    
    private func deleteGame(game: Game) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            viewContext.delete(game)
            
            // delete any players that have already been deleted
            game.scoresArray.forEach { playerScore in
                guard let player = playerScore.player else {
                    return
                }
                
                if player.hasBeenDeleted {
                    viewContext.delete(player)
                }
            }
            
            try! viewContext.save()
        }
    }
    
    private func duplicateGame(game: Game) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            Game.duplicateGame(context: viewContext, gameToDuplicate: game)
            
            try! viewContext.save()
        }
    }
}

struct GamesView_Previews: PreviewProvider {
    static var previews: some View {
        GamesListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
