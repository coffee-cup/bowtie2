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
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
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
                                self.deleteGame(game: game)
                            }) {
                                HStack {
                                    Text("Delete Game")
                                    Image(systemName: "trash")
                                }
                            }
                            
                            
                        }
                    }
                }
            }
            .padding(.horizontal)
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
        }
    }
    
    private func deleteGame(game: Game) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            viewContext.delete(game)
            
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
