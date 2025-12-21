//
//  ScoreHistoryView.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-28.
//

import SwiftUI

struct ScoreHistoryView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var playerScore: PlayerScore
    
    @State private var title = "Score history"
    
    var body: some View {
        NavigationStack {
            Group {
                if playerScore.wrappedHistory.count == 0 {
                    Text("No scores entered so far")
                        .fontWeight(.bold)
                        .padding()
                } else {
                    List {
                        ForEach(playerScore.wrappedHistory.reversed(), id: \.self) { item in
                            Text("\(item)")
                        }
                        .onDelete(perform: deleteItems)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            self.title = "Score history for \(playerScore.player?.wrappedName ?? "No name"    )"
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            var history = playerScore.wrappedHistory
            offsets.forEach { history.remove(at: history.count - 1 - $0) }
            playerScore.history = history
            
            if let game = playerScore.game {
                viewContext.refresh(game, mergeChanges: true)
            }
            
            viewContext.refresh(playerScore, mergeChanges: true)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ScoreHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreHistoryView(playerScore: Game.gameByName(context: PersistenceController.preview.container.viewContext, name: "Blitz")!.scoresArray[0])
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
