//
//  ScoreHistoryView.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-28.
//

import SwiftUI

struct ScoreHistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var playerScore: PlayerScore
    
    var body: some View {
        VStack {
            Text("Score history for \(playerScore.player?.wrappedName ?? "No name"    )")
                .font(.callout)
                .padding(.top, 32)
            
            List {
                ForEach(playerScore.wrappedHistory, id: \.self) { item in
                    Text("\(item)")
                }
                .onDelete(perform: deleteItems)
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            var history = playerScore.wrappedHistory
            offsets.forEach { history.remove(at: $0) }
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
