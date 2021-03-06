//
//  GameView.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-21.
//

import SwiftUI

fileprivate class GameViewSheetState: Identifiable {
    var addingScore: PlayerScore?
    var playerHistory: PlayerScore?
    
    init(adding addingScore: PlayerScore?,
         history playerHistory: PlayerScore?) {
        self.addingScore = addingScore
        self.playerHistory = playerHistory
    }
    
    static func addingScore(for player: PlayerScore) -> GameViewSheetState {
        return GameViewSheetState.init(adding: player, history: nil)
    }
    
    static func viewHistory(for player: PlayerScore) -> GameViewSheetState {
        return GameViewSheetState.init(adding: nil, history: player)
    }
}

struct GameView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var settings: UserSettings
    
    @ObservedObject var game: Game
    @State private var addingScore: PlayerScore? = nil
    @State private var sheetState: GameViewSheetState? = nil
    
    var body: some View {
        ScrollView {
            ForEach(game.scoresArray, id: \.self) { score in
                Button(action: {
                    sheetState = GameViewSheetState.addingScore(for: score)
                }) {
                    PlayerScoreCard(name: score.player!.wrappedName,
                                    colour: score.player!.wrappedColor,
                                    score: score.currentScore,
                                    numTurns: score.history!.count,
                                    maxScoresGame: game.maxNumberOfEntries)
                }
                .contextMenu {
                    Button(action: {
                        sheetState = GameViewSheetState.viewHistory(for: score)
                    }) {
                        HStack {
                            Text("View History")
                            Image(systemName: "archivebox")
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            if settings.showGraph && game.maxNumberOfEntries >= 2 {
                GameGraph(game: game)
                    .frame(maxWidth: .infinity, idealHeight: 200)
                    .padding(.horizontal)
            } else {
                EmptyView()
            }
        }
        .navigationBarTitle(game.wrappedName, displayMode: .large)
        .toolbar {
            NavigationLink(
                destination: GameSettings(game: game),
                label: {
                    Label("Game settings", systemImage: "gearshape")
                })
        }
        .sheet(item: $sheetState, content: presentSheet)
    }
    
    @ViewBuilder
    private func presentSheet(for sheet: GameViewSheetState) -> some View {
        if let addingScore = sheet.addingScore {
            EnterScoreView(playerScore: addingScore, addScore: addScore)
                .environmentObject(settings)
        } else if let playerHistory = sheet.playerHistory {
            ScoreHistoryView(playerScore: playerHistory)
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
                .environmentObject(UserSettings())
        }
    }
}
