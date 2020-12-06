//
//  GameSettings.swift
//  bowtie2
//
//  Created by Jake Runzer on 2020-11-29.
//

import SwiftUI

struct GameSettings: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var game: Game
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Game Name")) {
                    TextField("Name", text: Binding($game.name, ""), onCommit: {})
                }
                
                Section(header: Text("Winner")) {
                    Picker(selection:
                            Binding(
                                get: { game.winnerSort },
                                set: { value in
                                    self.game.winnerSort = value
                                }
                            ),
                           label: Text("Winner sort order")) {
                        ForEach(WinnerSort.allCases, id: \.self.rawValue) { value in
                            Text(value.stringValue).tag(value)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("Game Settings")
        }
        .onDisappear {
            self.saveGame()
        }
    }
    
    private func saveGame() {
        do {
            viewContext.refresh(game, mergeChanges: true)
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct GameSettings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GameSettings(game:
                            Game.gameByName(context: PersistenceController.preview.container.viewContext, name: "Blitz")!)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
