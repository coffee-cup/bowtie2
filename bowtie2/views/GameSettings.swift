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
    @State var selection: Int = 2
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Game Name")){
                    TextField("Name", text: Binding($game.name, "")) { _ in } onCommit: {
                        print("COMMIT")
                    }
                }
                
                Section(header: Text("Sort Players")) {
                    Picker(selection: Binding(get: {
                        return selection
                    }, set: { value in
                        self.selection = value
                        game.sortOrder = Int16(value)
                    }), label: Text("Player sort order")) {
                        ForEach(SortOrder.allCases, id: \.self.rawValue) { value in
                            Text(value.stringValue).tag(value.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("Game Settings")
        }
        .onAppear {
            self.selection = Int(game.sortOrder)
        }
        .onDisappear {
            self.saveGame()
        }
    }
    
    private func saveGame() {
        do {
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
