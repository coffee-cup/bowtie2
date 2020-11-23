//
//  GameView.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-21.
//

import SwiftUI

struct GameView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var game: Game
    
    @State private var addingScore: PlayerScore? = nil

    
    var body: some View {
        ScrollView {
            ForEach(game.scoresArray, id: \.self) { score in
                PlayerScoreCard(name: score.player!.wrappedName,
                                colour: score.player!.wrappedColor,
                                score: score.currentScore,
                                numTurns: score.history!.count,
                                maxScoresGame: game.maxNumberOfEntries)
                    .onTapGesture(count: 1, perform: {
                        self.addingScore = score
                    })
            }
            .padding(.horizontal)
        }
        .navigationBarTitle(game.wrappedName, displayMode: .large)
        .sheet(item: $addingScore, onDismiss: {
            self.addingScore = nil
        }) { item in
            EnterScoreView(playerScore: item, addScore: addScore)
        }
    }
    
    private func addScore(playerScore: PlayerScore, score: Int) {
        do {
            let currentPlayerScore = viewContext.object(with: playerScore.objectID) as! PlayerScore
            
            if currentPlayerScore.history == nil {
                currentPlayerScore.history = []
            }
            
            currentPlayerScore.history?.append(score)
            
            viewContext.refresh(currentPlayerScore, mergeChanges: true)
            viewContext.refresh(currentPlayerScore.game!, mergeChanges: true)
            viewContext.refresh(currentPlayerScore.player!, mergeChanges: true)
            
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            GameView(game: Game.gameByName(context: PersistenceController.preview.container.viewContext, name: "Blitz")!)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
